class CustomersController < ApplicationController
  before_filter :is_login?
  before_filter :access_role?
  before_filter :gmap_json, :only => ["edit"]
  #before_filter :trial_period_expired?

  # GET /customers
  def index
    if params[:cust]== 'inactive_customer'
      @customers = current_login.customers.search(params[:search]).where(:status => "Inactive").paginate(:per_page => 10, :page => params[:page])
    else
      @customers = current_login.customers.search(params[:search]).where(:status => "Active").paginate(:per_page => 10, :page => params[:page])
    end
    
    #@customers = current_login.customers.paginate :per_page => 10, :page => params[:page], :joins => :contacts, :conditions => ['customers.company_name ILIKE ? OR customers.types ILIKE ? OR contacts.name ILIKE ? OR contacts.email ILIKE?',"%#{params[:search]}%", "%#{params[:search]}%","%#{params[:search]}%", "%#{params[:search]}%" ], :order => 'customers.id'
  end
  
  
  # GET /customers/1
  def show
    @customer = Customer.find(params[:id])
  end
  
  # GET /customers/new
  def new
    @customer = Customer.new
    @jobsites = Jobsite.all.find(params[:customer_id]) 
 	end

  # GET /customers/1/edit
  def edit
    session[:customer_id] = params[:id]
    @customer = Customer.find(session[:customer_id])
    @customer_old_name = @customer.company_name #required to find records from QuickBooks and for updation
  end

  # POST /customers
  def create
    @customer = Customer.new(params[:customer])
    @customer.company_id = current_company.id

    @phone1 = params[:customer][:phone1]
    @phone2 = params[:customer][:phone2]
    @phone3 = params[:customer][:phone3]
    @phone4 = params[:customer][:phone4]
    unless params[:customer][:website].present? || params[:customer][:website] != ""
      params[:customer][:website] = "http://"
    end

    if @customer.save
      # check whether SMO is connected with QBO or not
      if current_company.present? && @customer.types != "Prospect"
        if current_company.access_token.present? && current_company.access_secret.present? && current_company.realm_id.present?
          push_to_quickbook(@customer) # push if not prospect customer
          flash[:notice] = t('customers.create.created')
        else
          flash[:alert] = t('customers.create.alert')
          flash[:notice] = t('customers.create.create_smo')
        end
      else
        flash[:notice] = t('customers.create.notice')
      end
      
      redirect_to customers_path
    else
      render :action => "new"
    end
  end

  # PUT /customers/1
  def update
    @customer = Customer.find(params[:id])
    @phone1 = params[:customer][:phone1]
    @phone2 = params[:customer][:phone2]
    @phone3 = params[:customer][:phone3]
    @phone4 = params[:customer][:phone4]

    if @customer.update_attributes(params[:customer])
      if current_company.present? && @customer.types != "Prospect"
        if current_company.access_token.present? && current_company.access_secret.present? && current_company.realm_id.present?
          update_to_quickbooks(@customer)   #update if not prospect customer
          flash[:notice] = t('customers.update.updated')
        else
          flash[:alert] = t('customers.update.alert')
          flash[:notice] = t('customers.update.notice')
        end
      else
        flash[:notice] = t('customers.update.notice_smo')
      end

      redirect_to customers_path
    else
      render :action => "edit"
    end
  end

  # DELETE /customers/1
  def destroy
    @customer = Customer.find(params[:id])
    if @customer.destroy
      flash[:notice] = t('customers.destroy.notice')
    else
      flash[:error] = t('customers.destroy.error')
    end
    redirect_to customers_url
  end

  #push into QuickBooks
  def push_to_quickbook(customers)
    #push data to QuickBooks
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_company.access_token, current_company.access_secret)

    #creating customer in quickbooks
    customer_service = Quickeebooks::Online::Service::Customer.new
    customer_service.access_token = oauth_client
    customer_service.realm_id = current_company.realm_id
    # customer_service.list

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
    
    if params[:controller]=="customers" && params[:action]=="edit"
      if customer.contact.presents?
      email = Quickeebooks::Online::Model::Email.new
      email.address = @customer.contact.email
      customer.email_address = email
      end
     end
              
    # check for duplicate customers
    filter_duplicate_customer = []
    filter_duplicate_customer << Quickeebooks::Online::Service::Filter.new(:text, :field => 'name', :value => customer.name )
    customer_exists = customer_service.list(filter_duplicate_customer)
    
    if customer_exists.entries.present?
      unless params[:controller]=="customers" && params[:action]=="edit"
        flash[:alert] = "Customer with this name is already in QBO. You can update this customer now"
      end
    else
      #create customer with these datas
      customer_service.create(customer) 
      
      filters = []
      filters << Quickeebooks::Online::Service::Filter.new(:text, :field => 'name', :value => customer.name)
      customer_exists = customer_service.list(filters)
    end
    
    @customer = current_company.customers.find(@customer.id)
    quickbook_customer_id = customer_exists.entries.first.id

    #update quickbook_customer_id field in customer table
    @customer.update_attributes(:quickbook_customer_id => quickbook_customer_id)
  end


  
  def update_to_quickbooks(customers)
    #push data to QuickBooks
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_company.access_token, current_company.access_secret)

    #creating customer in QuickBooks
    customer_service = Quickeebooks::Online::Service::Customer.new
    customer_service.access_token = oauth_client
    customer_service.realm_id = current_company.realm_id
    #    customer_service.list

    unless @customer.quickbook_customer_id.present? || @customer.quickbook_customer_id != nil
      push_to_quickbook(@customer)
    else
      customer = customer_service.fetch_by_id(@customer.quickbook_customer_id)

      # update old values to new value here
      customer.name = @customer.company_name
    
      #update addresses
      unless customer.addresses.present?
        address = Quickeebooks::Online::Model::Address.new
        address.line1 = @customer.address1
        address.line2 = @customer.address2
        address.city = @customer.city
        address.country_sub_division_code = @customer.state
        address.postal_code = @customer.zip
        customer.addresses = [address]
      else
        customer.addresses.first.line1 = @customer.address1
        customer.addresses.first.line2 = @customer.address2
        customer.addresses.first.city = @customer.city
        customer.addresses.first.country_sub_division_code = @customer.state
        customer.addresses.first.postal_code = @customer.zip
      end

      #update phones
      # phones fields is empty create contact else update
      unless customer.phones.present?
        phone1 = Quickeebooks::Online::Model::Phone.new
        phone1.device_type = "Primary"
        phone1.free_form_number = (@customer.phone.present? ? @customer.phone : "-")
        phone2 = Quickeebooks::Online::Model::Phone.new
        phone2.device_type = "Mobile"
        phone2.free_form_number = (@customer.phone.present? ? @customer.phone : "-")
        customer.phones = [phone1, phone2]
      else
        customer.phones.first.free_form_number = @customer.phone
        customer.phones.second.free_form_number = @customer.phone
      end

      #update website uri
      customer.web_site.uri = @customer.website
      
      if Contact.exists?(:customer_id => params[:id])
      @contact = Contact.find_by_customer_id(params[:id])
      customer.email_address = @contact.email
      end
      
      customer_service.update(customer)
    end
  end
  
  def inactive_cust
    @customers = current_login.customers.search(params[:search]).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    @customer= Customer.find(params[:id])
    @customer.update_attribute(:status, "Inactive")
    flash[:notice]="Customer has been Inactivated."
    redirect_to customers_path
  end
  
  def active_cust
    @customers = current_login.customers.search(params[:search]).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    @customer = Customer.find(params[:id])
    @customer.update_attribute(:status, "Active")
    flash[:notice]="Customer has been Activated."
    redirect_to customers_path
  end
end
