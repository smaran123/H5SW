class SettingsController < ApplicationController
  before_filter :is_login?
  before_filter :access_role?
  #before_filter :trial_period_expired?
  
  
  def index
    @businesses = current_login.businesses.paginate(:per_page => 10, :page => params[:page1])
    @jobstatus = current_login.jobstatuses.paginate(:per_page => 10, :page => params[:page2])
  end
  
  def accounting
    
  end
  
  def authenticate
    callback = oauth_callback_settings_url
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = token
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end
  
  def oauth_callback
    at = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    access_token = at.token
    access_secret = at.secret
    realm_id = params['realmId']
    
    # clear cache for bluedot menu so that it will display updated connections
    Rails.cache.clear
    
    confirm_token_update(access_token, access_secret, realm_id)
  end
  
  def dis_quickbooks
    if signed_in?
      # find connected services
      set_qb_service('AccessToken')   
         
      # disconnect connected services
      result = @service.disconnect
    
      # send the status result
      if result.error_code == '270'
        msg = 'Disconnect failed as OAuth token is invalid. Try connecting again.'
      else
        msg = 'Successfully disconnected from QuickBooks'
      end
    
      company = Company.where(id: current_company.id).first
      company.access_token  = nil
      company.access_secret = nil
      company.realm_id      = nil
      company.save!(validate: false)

      redirect_to accounting_settings_path, notice: msg
    end
  end
  
  def bluedot
    access_token = current_company.access_token
    access_secret = current_company.access_secret
    consumer = OAuth::AccessToken.new($qb_oauth_consumer, access_token, access_secret)
    response = Rails.cache.fetch(["!|0v3#@ck", "blue_dot_menu"]){
      response = consumer.request(:get, "https://appcenter.intuit.com/api/v1/Account/AppMenu")
    }
    if response && response.body
      html = response.body
      render(:text => html) and return
    else
      Rails.cache.clear
    end
  end

  # sync all customer from QuickBooks to SMO and vice versa
  def sync_customer_data
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_company.access_token, current_company.access_secret)

    customer_service = Quickeebooks::Online::Service::Customer.new
    customer_service.access_token = oauth_client
    customer_service.realm_id = current_company.realm_id

    #load all the customers created in QuickBooks
    @customers = []
    200.times do |i|
      temp_cust = customer_service.list(filters = [], page = i+1, per_page = 500, sort = nil, options = {}).entries
      @customers += temp_cust
      break if temp_cust.empty?
    end  

    
    # find the list of customers that don't have either city, state or zipcode in quickbooks
    # and if found display error message for those customers
    @customers_without_address = []
    
    #check the condition for each customer either they exists in our application or not
    #if any of the customer doesnot exists in our application then create new customer
    #with QuickBooks customer values
    @customers.each do |customer|
      @customer_id     = customer.try(:id)
      @customer_name   = customer.try(:name)
      @city            = customer.try(:addresses).try(:first).try(:city)
      @state           = customer.try(:addresses).try(:first).try(:country_sub_division_code)
      @zipcode         = customer.try(:addresses).try(:first).try(:postal_code)
      @address1        = customer.try(:addresses).try(:first).try(:line1)
      @address2        = customer.try(:addresses).try(:first).try(:line2)
      @phone           = customer.try(:phones).try(:first).try(:free_form_number)
      @website         = customer.try(:web_site).try(:uri)
      
      
      if @city.blank? || @state.blank? || @zipcode.blank?
        @customers_without_address << @customer_name
      end
      
      
      #sync terms client
      customer = customer_service.fetch_by_id(customer.id.to_i)
      if customer.sales_term_id.present?
        sales_term_id         = customer.sales_term_id.value
        service               = Quickeebooks::Online::Service::SalesTerm.new
        service.access_token  = oauth_client
        service.realm_id      = current_company.realm_id

        sales_term            = service.fetch_by_id(sales_term_id)
        @terms_client         = sales_term.try(:name)
      end
      
      
      # if customer donot exists in our database directly create them
      # if they already exists then, update them
      unless current_company.customers.exists?(:quickbook_customer_id => @customer_id.to_i)
        current_company.customers.create(:types => "Customer", :account => " ", :company_name => @customer_name, :address1 => @address1, :address2 => @address2, :city => @city, :state => @state, :zip => @zipcode, :phone => @phone, :website => @website, :quickbook_customer_id => @customer_id, :terms_client => @terms_client )
      else
        current_company.customers.find_or_create_by_company_name(:company_name => @customer_name).update_attributes(:types => "Customer", :account => " ", :company_name => @customer_name, :address1 => @address1, :address2 => @address2, :city => @city, :state => @state, :zip => @zipcode, :phone => @phone, :website => @website, :quickbook_customer_id => @customer_id, :terms_client => @terms_client )
      end
    end
    
    @customers_without_address

    # push non-existing customers to QBO from SMO
    qbo_customers = []
    smo_customers = []
    non_matching_customers = []

    qbo_customers = @customers.map{|c| [c.name]}
    smo_customers = current_company.customers.where("types!=?", "Prospect").map{|c| [c.company_name]}
    
    
    non_matching_customers = smo_customers - qbo_customers # non matching in SMO, push these to QuickBooks
    non_matching_customers.each do |customer|
      smo_customers = current_company.customers.find_by_company_name(customer)
      push_to_quickbook(smo_customers)
    end
  rescue OAuth::Problem
    session[:alert] = "OAuth::Problem - token_rejected. Please Reconnect to QBO"
  rescue IntuitRequestException 
    session[:alert] = " Another $$customer$$ is already using this name. Please use a different name."
  
    session[:last_seen] = Time.now
  end

  # push SMO_customer_to_quickbook
  def push_to_quickbook(customers)
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_company.access_token, current_company.access_secret)

    customer_service = Quickeebooks::Online::Service::Customer.new
    customer_service.access_token = oauth_client
    customer_service.realm_id = current_company.realm_id

    @customer = customers
    
    customer = Quickeebooks::Online::Model::Customer.new

    customer.name = @customer.company_name
    #customer.email = Quickeebooks::Online::Model::Email.new(@customer.email)

    address = Quickeebooks::Online::Model::Address.new
    address.line1 = @customer.address1
    address.line2 = @customer.address2
    address.city = @customer.city
    address.country_sub_division_code = @customer.state
    address.postal_code = @customer.zip
    customer.addresses = [address]

    phone1 = Quickeebooks::Online::Model::Phone.new
    phone1.device_type = "Primary"
    phone1.free_form_number = (@customer.phone.present? ? @customer.phone : "-")
    phone2 = Quickeebooks::Online::Model::Phone.new
    phone2.device_type = "Mobile"
    phone2.free_form_number = (@customer.phone.present? ? @customer.phone : "-")
    customer.phones = [phone1, phone2]

    website = Quickeebooks::Online::Model::WebSite.new
    website.uri = @customer.website
    customer.web_site = website

    #create customer with these datas
    customer_service.create(customer)

    filters = []
    filters << Quickeebooks::Online::Service::Filter.new(:text, :field => 'name', :value => customer.name)
    customer = customer_service.list(filters)
    @customer = current_company.customers.find(@customer.id)
    quickbook_customer_id = customer.entries.first.id

    #update quickbook_customer_id field in customer table
    @customer.update_attributes(:quickbook_customer_id => quickbook_customer_id)
  end


  

  # sync all items from QuickBooks
  def sync_items
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_company.access_token, current_company.access_secret)

    item_service = Quickeebooks::Online::Service::Item.new
    item_service.access_token = oauth_client
    item_service.realm_id = current_company.realm_id

    #load all the customers created in QuickBookss
    @items = []
    500.times do |i|
      temp_item = item_service.list(filters = [], page = i+1, per_page = 500, sort = nil, options = {}).entries
      @items += temp_item
      break if temp_item.empty?
    end  


    @items.each do |item|
      if !current_company.items.exists?(:name => item.name)
        current_company.items.create(:quickbook_item_id => item.id, :name => item.name, :description => item.desc, :unit_price => item.unit_price.present? ? item.unit_price.amount : 0, :unit_cost => 0, :itemtype => "Quickbook", :qty => 1, :number => "-")
      else
        @item = current_company.items.find_by_name(item.name)
        @item.update_attributes(:quickbook_item_id => item.id, :name => item.name, :description => item.desc, :unit_price => item.unit_price.present? ? item.unit_price.amount : 0, :unit_cost => 0, :itemtype => "Quickbook", :qty => 1, :number => "-")
      end
    end
  rescue OAuth::Problem
    flash[:alert] = "OAuth::Problem - token_rejected. Please Reconnect to QBO"
  end


  def sync_employees
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_company.access_token, current_company.access_secret)

    user_service = Quickeebooks::Online::Service::Employee.new
    user_service.access_token = oauth_client
    user_service.realm_id = current_company.realm_id

    # find sub-contractor role
    @role = current_company.roles.find_or_create_by_roll("Tech")
    @role_id = @role.id
    
    # load all the employees
    @employees = []
    100.times do |i|
      temp_employee = user_service.list(filters = [], page = i+1, per_page = 100, sort = nil, options = {}).entries
      @employees += temp_employee
      break if temp_employee.empty?
    end  

    # check for existing value
    @employees.each do |employee|
      unless current_company.users.exists?(:name => employee.name, :role_id => @role_id)
        #email = (employee.email.present? ? employee.email.address : "#{SecureRandom.urlsafe_base64 + "@gmail.com"}")
        email = employee.email.present? ? employee.email.address : "-"
        @user = current_company.users.new(:password => "qawsed!@#", :password_confirmation => "qawsed!@#", :role_id => @role_id, :name => employee.name, :accounting_name => employee.name, :email => email, :smo_user => false, :language => "English", :company_id => current_company.id, :time_zone => "Hawaii", :accounting_type => "Employee")
        @user.save(:validate => false)
      end
    end
  rescue OAuth::Problem
    flash[:alert] = "OAuth::Problem - token_rejected. Please Reconnect to QBO"
  end



  def sync_vendors
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_login.access_token, current_login.access_secret)

    vendor_service = Quickeebooks::Online::Service::Vendor.new
    vendor_service.access_token = oauth_client
    vendor_service.realm_id = current_login.realm_id

    # find sub-contractor role
    @role = current_login.roles.find_or_create_by_roll("Subcontractor") 
    @role_id = @role.id
    
    # load all the employees
    @vendors = []
    100.times do |i|
      temp = vendor_service.list(filters = [], page = i+1, per_page = 100, sort = nil, options = {}).entries
      @vendors += temp
      break if temp.empty?
    end  
    
    # check for existing value
    @vendors.each do |vendor|
      unless current_login.users.exists?(:name => vendor.name, :role_id => @role_id)
        #email = (vendor.email.present? ? vendor.email.address : "#{SecureRandom.urlsafe_base64 + "@gmail.com"}") # if email present
        email = vendor.email.present? ? vendor.email.address : "-"
        @user = current_login.users.new(:password => "qawsed!@#", :password_confirmation => "qawsed!@#", :role_id => @role_id, :name => vendor.name, :accounting_name => vendor.name, :email => email, :smo_user => false, :language => "English", :company_id => current_login.id, :time_zone => "Hawaii", :accounting_type => "Vendor")
        @user.save(:validate => false)
        
      end
    end
   
    p @vendors
  rescue OAuth::Problem
    flash[:alert] = "OAuth::Problem - token_rejected. Please Reconnect to QBO"
  end



  def sync_salse_person
    # sync Rep
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_login.access_token, current_login.access_secret)

    rep_service = Quickeebooks::Online::Service::Rep.new
    rep_service.access_token = oauth_client
    rep_service.realm_id = current_login.realm_id

    # find sub-contractor role
    @role_id = current_login.roles.find_by_roll("Sales").id if current_login.roles.exists?(:roll => "Sales")

    # load all the employees
    @sales_persons = user_service.list.entries

    # check for existing value
    @sales_persons.each do |sales_person|
      unless current_login.users.exists?(:name => sales_person.name, :role_id => @role_id)
        email = (sales_person.email.present? ? sales_person.email.address : "#{SecureRandom.urlsafe_base64 + "@gmail.com"}")
        current_login.users.new(:password => "qawsed!@#", :password_confirmation => "qawsed!@#", :role_id => @role_id, :name => sales_person.name,
          :accounting_name => sales_person.name, :email => email, :smo_user => false, :language => "English",
          :company_id => current_login.id, :time_zone => "Hawaii", :accounting_type => "Customer")
      end
    end
  end
  
end
