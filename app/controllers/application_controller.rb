class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from Exception, :with => :handle_exceptions

  helper :all
  helper_method :search_by_session
  helper_method :expired_on
  helper_method :current_login
  before_filter :set_locale
  layout :get_layout?
  
  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end
  
  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(Superadmin)
      superadmin_dashboards_path
    else
      if current_login.status == "Inactive"
        sign_out(current_login)
        flash[:alert] = "You are not allowed to login"
        root_path
      else
        root_path
      end
    end
  end

  def after_sign_up_path_for(resource_or_scope)
    after_sign_in_path_for(resource_or_scope)
  end

  def is_login?
    unless current_company or current_user
      flash[:error] = "Please login"
      redirect_to '/'
    end
  end

  def confirm_token_update(access_token, access_secret, realm_id)
    company = Company.where(id: current_company.id).first
    company.access_token  = access_token
    company.access_secret = access_secret
    company.realm_id      = realm_id
    company.save(validate: false)
    
    unless session[:single_sign_on] == true
      render
    else
      session[:single_sign_on]     = nil
      flash[:flash] = "Successfully connected with your QuickBooks account"
      redirect_to root_path
    end
  end
  
  def session_types
    @job_id = session[:job_id]
    @customer_id = session[:customer_id]
    @jobsite_id = session[:jobsite_id]
    
    @job_id ? @job = Job.find(@job_id) : nil
    @customer_id ? @customer_id=="All"  || @customer_id == 0 ? nil : @customer = Customer.find(@customer_id) : nil
    @jobsite_id ? (@jobsite_id == "All" || @jobsite_id == "None" || @jobsite_id == 0) ? nil : @jobsite = Jobsite.find(@jobsite_id) : nil
  end

  #only applicable for jobsite
  def search_by_customer_id(value)
    if session[:customer_id]
      if session[:customer_id] == "All"
        value
      else
        value.where('customer_id=?', session[:customer_id])
      end
    else
      value
    end
  end

  def search_by_session(value)
    if session[:customer_id] && session[:jobsite_id]
      if session[:customer_id]=="All" && (session[:jobsite_id] == "All" || session[:jobsite_id] == "None")
        value
      elsif session[:customer_id]!="All" && (session[:jobsite_id] == "All" || session[:jobsite_id] == "None")
        value.where('customer_id=?', session[:customer_id])
      elsif session[:customer_id]=="All" && (session[:jobsite_id] != "All" || session[:jobsite_id] != "None")
        value
      else
        value.where('customer_id=? AND jobsite_id=?', session[:customer_id], session[:jobsite_id])
      end
    elsif session[:customer_id] && !session[:jobsite_id]
      if session[:customer_id]=="All"
        value
      else
        value.where('customer_id=?', session[:customer_id])
      end
    else
      value
    end
  end

  def search_by_session_type(model_type, value, type)
    if session[:customer_id] && session[:jobsite_id]
      if session[:customer_id]=="All" && (session[:jobsite_id] == "All" || session[:jobstie_id] == "None")
        if model_type=="document"
          value.where('documentable_type=?', type)
        elsif model_type == "note"
          value.where('notable_type=?', type)
        end
      elsif session[:customer_id]!="All" && (session[:jobsite_id] == "All" || session[:jobsite_id] == "None")
        if model_type=="document"
          value.where('documentable_type=? AND documentable_id=?', type, session[:customer_id])
        elsif model_type=="note"
          value.where('notable_type=? AND notable_id=?', type, session[:customer_id])
        end
      elsif session[:customer_id]=="All" && (session[:jobsite_id] != "All" || session[:jobsite_id] != "None")
        if model_type=="document"
          value.where('documentable_type=?', type)
        elsif model_type=="note"
          value.where('notable_type=?', type)
        end
      else
        if model_type=="document"
          value.where('documentable_type=? AND documentable_id=? AND jobsite_id=?', type, session[:customer_id], session[:jobsite_id])
        elsif model_type=="note"
          value.where('notable_type=? AND notable_id=? AND jobsite_id=?', type, session[:customer_id], session[:jobsite_id])
        end
      end
    elsif session[:customer_id] && !session[:jobsite_id]
      if session[:customer_id]=="All"
        if model_type=="document"
          value.where('documentable_type=?', type)
        elsif model_type=="note"
          value.where('notable_type=?', type)
        end
      else
        if model_type=="document"
          value.where('documentable_type=? AND documentable_id=?', type, session[:customer_id])
        elsif model_type=="note"
          value.where('notable_type=? AND notable_id=?', type, session[:customer_id])
        end
      end
    else
      if model_type=="document"
        value.where('documentable_type=? ', type)
      elsif model_type=="note"
        value.where('notable_type=? ', type)
      end
    end
  end

  def gmap_json
    if !session[:customer_id].nil? && !session[:jobsite_id].nil? && session[:jobsite_id] != 0
      if session[:customer_id]=="All" && (session[:jobsite_id] == "All" || session[:jobsite_id] == "None")
        @json1 = Customer.all.to_gmaps4rails
        @json2 = Jobsite.all.to_gmaps4rails
      elsif session[:customer_id]!="All" && (session[:jobsite_id] == "All" || session[:jobsite_id] == "None")
        @json1 = Customer.find_by_id(session[:customer_id]).to_gmaps4rails
        @json2 = Jobsite.find_all_by_customer_id(session[:customer_id]).to_gmaps4rails
      elsif session[:customer_id]=="All" && (session[:jobsite_id] != "All" || session[:jobsite_id] != "None")
        @json1 = Customer.all.to_gmaps4rails
        @json2 = Jobsite.find_by_id(session[:jobsite_id]).to_gmaps4rails
      else
        @json1 = Customer.find_by_id(session[:customer_id]).to_gmaps4rails
        @json2 = Jobsite.find_by_id(session[:jobsite_id]).to_gmaps4rails
      end
    end
    if !@json2.nil? and !@json1.nil?
      @json = (JSON.parse(@json1) + JSON.parse(@json2)).to_json
    elsif @json2.nil? and !@json1.nil?
      @json = JSON.parse(@json1).to_json
    elsif !@json2.nil? and @json1.nil?
      @json = JSON.parse(@json2).to_json
    else
      @json = []
    end
  end


  # Actions for trial period
  # Create expired_on action for keeping track of how many days remaining in trial period
  # Create payment_notification after 20 days passed and 30 days passed
  # Create trial_period_expired? redirecting to expire notification page after trial expiration
  def expired_on
    curr_company = Company.find(current_login.id)
    ((curr_company.subscription_date.to_date + 30.days).to_date - Date.today).round if curr_company.present?
  end

  def payment_notification
    # send current_login email for subscription
  end
  
  
  def trial_period_expired?
    if expired_on <= 0
      redirect_to subscriptions_path
    end
  end
  # end of Actions for trial period


  # accessing the role set for each user
  def current_login
    current_company ? current_company : current_user.company
  end

  def access_role?
    unless current_company.present?
      if (params[:controller] == "settings" && params[:action] == "accounting")
        flash[:alert] = t('application.alert')
        redirect_to users_path
      end
    end

    if current_user
      @user_role = Role.find(current_user.role_id)
      @user_role ? @role_name = @user_role.roll : ""
      @error_message = t('application.error')
    
      if @user_role
        if @role_name == "Admin"
        else
        
          #customer role
          @customer_role =  @user_role.customer
          if @customer_role == "All"
          elsif @customer_role == "None"
            if params[:controller] == "customers"
              flash[:alert] = @error_message
              redirect_to dashboards_index_path
            end
          elsif @customer_role == "Read-Only"
            if params[:controller] == "customers" && (params[:action] == "edit" || params[:action] == "new")
              flash[:alert] = @error_message
              redirect_to customers_path
            end
          elsif @customer_role == "Add/Read"
            if params[:controller] == "customers" && params[:action] == "edit"
              flash[:alert] = @error_message
              redirect_to customers_path
            end
          end

          #jobs role
          @job_role =  @user_role.jobs
          if @job_role == "All"
          elsif @job_role == "None"
            if params[:controller] == "jobs"
              flash[:alert] = @error_message
              redirect_to dashboards_index_path
            end
          elsif @job_role == "Read-Only"
            if params[:controller] == "jobs" && (params[:action] == "edit" || params[:action] == "new")
              flash[:alert] = @error_message
              redirect_to jobs_path
            end
          elsif @job_role == "Add/Read"
            if params[:controller] == "jobs" && params[:action] == "edit"
              flash[:alert] = @error_message
              redirect_to jobs_path
            end
          end

          #jobtimes role
          @jobtime_role = @user_role.jobtimes
          if @jobtime_role == "Read-Write"
          elsif @jobtime_role == "None"
            if params[:controller] == "jobtimes"
              flash[:alert] = @error_message
              redirect_to dashboards_index_page
            end
          elsif @jobtime_role == "Read-Only"
            if params[:controller] == "jobtimes" && params[:action] == "new"
              flash[:alert] = @error_message
              redirect_to jobtimes_path
            end
          end

          #contacts role
          @contact_role =  @user_role.contacts
          if @contact_role == "All"
          elsif @contact_role == "None"
            if params[:controller] == "contacts"
              flash[:alert] = @error_message
              redirect_to dashboards_index_path
            end
          elsif @contact_role == "Read-Only"
            if params[:controller] == "contacts" && (params[:action] == "edit" || params[:action] == "new")
              flash[:alert] = @error_message
              redirect_to contacts_path
            end
          elsif @contact_role == "Add/Read"
            if params[:controller] == "contacts" && params[:action] == "edit"
              flash[:alert] = @error_message
              redirect_to contacts_path
            end
          end
          


          #settings_admin role

          @settings_role =  @user_role.settings_admin
          unless @settings_role == "All"
            if params[:controller] == "users" || params[:controller] == "roles" || (params[:controller] == "customs" && params[:action] == "new") || (params[:controller] == "jobtimes" && params[:action] == "new") || params[:controller] == "settings"
              flash[:alert] = @error_message
              redirect_to dashboards_index_path
            end
          end
        end
      end
    end
  end


  def push_invoice_to_quickbook
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_login.access_token, current_login.access_secret)
    
    invoice_service = Quickeebooks::Online::Service::Invoice.new
    invoice_service.access_token = oauth_client
    invoice_service.realm_id = current_login.realm_id

    customer_service = Quickeebooks::Online::Service::Customer.new
    customer_service.access_token = oauth_client
    customer_service.realm_id = current_login.realm_id

    #check whether tokens are present or not
    if current_company.present?
      if current_company.access_token.present? && current_company.access_secret.present? && current_company.realm_id.present?
        @job = current_login.jobs.find(params[:id])
        @customer = current_login.customers.find(@job.customer_id)

        invoice = Quickeebooks::Online::Model::Invoice.new

        if current_login.inventories.exists?(:job_id => @job.id) || current_login.jobtimes.exists?(:job_id => @job.id)

          # created_at and updated_at
          meta_data = Quickeebooks::Online::Model::MetaData.new
          meta_data.create_time = @job.created_at
          meta_data.last_updated_time = @job.updated_at
          invoice.meta_data = meta_data

          # create header parts
          header = Quickeebooks::Online::Model::InvoiceHeader.new
          header.doc_number = @job.reference_no
          header.msg = @job.summary
          # find the customer in QuickBooks
          customer = customer_service.fetch_by_id(@customer.quickbook_customer_id)
          if customer.present?
            header.customer_id = customer.id
            header.customer_name = customer.name
          end
    
          # header.sub_total_amount = @job.sub_total
          header.to_be_printed = true
          header.to_be_emailed = true
          header.bill_email = current_login.email
          header.due_date = @job.due_date
          invoice.header = header

          @items = current_login.inventories.where("job_id = ?", @job.id)
          if @items.present?
            @items.each do |item|
              line_item = Quickeebooks::Online::Model::InvoiceLineItem.new
              if item.description.present?
                line_item.desc = item.description
              else
                line_item.desc = item.name
              end
              # line_items.item_id = Item.find(@job.item_id).quickbook_item_id
              line_item.unit_price = item.unit_price
              line_item.quantity = item.qty.to_f
              line_item.amount = (item.unit_price.to_f * item.qty.to_f)     # unit_price * qty

              # push each line items in invoice line_items
              invoice.line_items << line_item
            end
          end

          @items = current_login.jobtimes.where("job_id =?", @job.id)
          if @items.present?
            @items.each do |item|
              line_item = Quickeebooks::Online::Model::InvoiceLineItem.new
          
              hrs = item.qty.split(":")[0]
              min = item.qty.split(":")[1]
              sec = item.qty.split(":")[2]
          
              qty = hrs.to_f + min.to_f/60 + sec.to_f/3600
              line_item.quantity = qty
              line_item.unit_price = item.price.to_f/qty

              # display service item name in description
              service_item = Item.find(item.service)
              line_item.desc = service_item.name

              if item.billable == true
                line_item.amount = item.price
              end

              invoice.line_items << line_item
            end
          end
          invoice_service.create(invoice)
          @job.update_attributes(:status => 'invoiced')
          flash[:notice] = "Job invoiced successfully; QuickBooks Transaction  ##{@job.reference_no}"

          # mark job as invoiced, and also update tax_amount and
          # QuickBooks total amount for this job
          #          filters = []
          #          filters << Quickeebooks::Online::Service::Filter.new(:text, :field => 'doc_number', :value => @job.reference_no)
          #          invoice = invoice_service.list(filters)
        else
          flash[:alert] = t('application.alert1')
        end
      else
        flash[:alert] =  t('application.alert2')
      end
    end
  end
  
  def push_invoice_and_send_to_qbo
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_login.access_token, current_login.access_secret)
    
    invoice_service = Quickeebooks::Online::Service::Invoice.new
    invoice_service.access_token = oauth_client
    invoice_service.realm_id = current_login.realm_id

    customer_service = Quickeebooks::Online::Service::Customer.new
    customer_service.access_token = oauth_client
    customer_service.realm_id = current_login.realm_id

    #check whether tokens are present or not
    if current_company.present?
      if current_company.access_token.present? && current_company.access_secret.present? && current_company.realm_id.present?
        @job = current_login.jobs.find(params[:id])
        @customer = current_login.customers.find(@job.customer_id)

        invoice = Quickeebooks::Online::Model::Invoice.new

        if current_login.inventories.exists?(:job_id => @job.id) || current_login.jobtimes.exists?(:job_id => @job.id)

          # created_at and updated_at
          meta_data = Quickeebooks::Online::Model::MetaData.new
          meta_data.create_time = @job.created_at
          meta_data.last_updated_time = @job.updated_at
          invoice.meta_data = meta_data

          # create header parts
          header = Quickeebooks::Online::Model::InvoiceHeader.new
          header.doc_number = @job.reference_no
          header.msg = @job.summary
          # find the customer in QuickBooks
          customer = customer_service.fetch_by_id(@customer.quickbook_customer_id)
          if customer.present?
            header.customer_id = customer.id
            header.customer_name = customer.name
          end
    
          # header.sub_total_amount = @job.sub_total
          header.to_be_printed = true
          header.to_be_emailed = true
          header.bill_email = current_login.email
          header.due_date = @job.due_date
          invoice.header = header

          @items = current_login.inventories.where("job_id = ?", @job.id)
          if @items.present?
            @items.each do |item|
              line_item = Quickeebooks::Online::Model::InvoiceLineItem.new
              if item.description.present?
                line_item.desc = item.description
              else
                line_item.desc = item.name
              end
              # line_items.item_id = Item.find(@job.item_id).quickbook_item_id
              line_item.unit_price = item.unit_price
              line_item.quantity = item.qty.to_f
              line_item.amount = (item.unit_price.to_f * item.qty.to_f)     # unit_price * qty

              # push each line items in invoice line_items
              invoice.line_items << line_item
            end
          end

          @items = current_login.jobtimes.where("job_id =?", @job.id)
          if @items.present?
            @items.each do |item|
              line_item = Quickeebooks::Online::Model::InvoiceLineItem.new
          
              hrs = item.qty.split(":")[0]
              min = item.qty.split(":")[1]
              sec = item.qty.split(":")[2]
          
              qty = hrs.to_f + min.to_f/60 + sec.to_f/3600
              line_item.quantity = qty
              line_item.unit_price = item.price.to_f/qty

              # display service item name in description
              service_item = Item.find(item.service)
              line_item.desc = service_item.name

              if item.billable == true
                line_item.amount = item.price
              end

              invoice.line_items << line_item
            end
          end
          invoice_service.create(invoice)
          @job.update_attributes(:status => 'invoiced')
          send_invoice_qbo
          flash[:notice] = "Job invoiced successfully; QuickBooks Transaction  ##{@job.reference_no}"
        else
          flash[:alert] = t('application.alert1')
        end
      else
        flash[:alert] =  t('application.alert2')
      end
    end
  end
  
  private
  
  # QuickBooks find server before disconnecting them
  def set_qb_service(type = 'Vendor')
    access_token = current_company.access_token
    access_secret = current_company.access_secret
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, access_token, access_secret)
    @service = "Quickeebooks::Online::Service::#{type}".constantize.new
    @service.access_token = oauth_client
    @service.realm_id = current_company.realm_id
  end
  
  def get_layout?
    if current_superadmin
      return "superadmin"
    else
      return "application"
    end
  end
  
  def is_superadmin?
    unless current_superadmin
      flash[:alert] = "Please login with superadmin. you don't have permissions"
      redirect_to '/'
    end
  end
  
  def handle_exceptions(e)
    case e
    when OAuth::Problem
      flash[:alert] = "OAuth::Problem - token_rejected. Please Reconnect to QBO"
      redirect_to dashboards_index_path
    else
      flash[:alert] = "Error occurred : #{e}"
      redirect_to dashboards_index_path
    end
  end
end
