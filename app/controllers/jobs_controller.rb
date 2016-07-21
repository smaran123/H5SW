class JobsController < ApplicationController
  before_filter :is_login?
  before_filter :access_role?
  #before_filter :trial_period_expired?
  
  before_filter :session_types, :except => ["index", "show"]
  before_filter :find_id_by_role, :only => ["new", "edit", "create", "update"]

  def index
    if params[:my_job] == 'all jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search])).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    elsif params[:my_job]== 'unassigned jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search]).where(:assigned_to => "NULL")).paginate(:per_page => 10, :page => params[:page]).order("created_at desc")
    elsif params[:my_job] == 'my jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search]).where("status=? AND assigned_to!=?",'open','NULL')).paginate(:per_page => 10, :page => params[:page]).order("created_at desc")
    elsif params[:my_job] == 'closed jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search]).where(:status => "closed")).paginate(:per_page => 10, :page => params[:page]).order("created_at desc")
    elsif params[:my_job] == 'invoiced jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search]).where(:status => "invoiced")).paginate(:per_page => 10, :page => params[:page]).order("created_at desc")
    else
      @jobs = search_by_session(current_login.jobs.search(params[:search]).where(:status => "open")).paginate(:per_page => 10, :page => params[:page]).order("created_at desc")
    end
    if request.xhr?
      respond_to do |format|
        format.js 
      end
    end
  end
  

  def show
    @job = Job.find(params[:id])
  end
  

  def new
    @job = Job.new
  end
  

  def edit
    @job = Job.find(params[:id])
    @customer = Customer.find_by_id(@job.customer_id)
    @jobsite = Jobsite.find_by_id(@job.jobsite_id)
    session[:customer_id] = @job.customer_id
    session[:jobsite_id] = @job.jobsite_id
    session[:job_id] = @job.id
  end
  

  def create
    @job = Job.new(params[:job])
    @job.company_id = current_login.id
#    @note = current_login.notes.new
#    @notes = search_by_session_type("note",current_login.notes,"Job").order("created_at desc")
    if @job.save
      unless current_login.status == "paid"
        @value = current_login.jobs.where('created_at BETWEEN ? AND ?', current_login.new_company_period - 30.days, current_login.new_company_period)
      current_login.update_attributes!(:jobs_remaining => (30-@value.count).to_s)
      end
      session_job_id
        redirect_to jobs_path, :notice => t('jobs.create.notice')
    else
      render :action => "new"
    end
  end
  

  def job_pdf
    @job = Job.find(params[:id])
    render :pdf => "jobs/job_pdf.html.erb"
  end

  
  def update
    @job = Job.find(params[:id])
    params[:job][:customer_id] = session[:customer_id]
    params[:job][:jobsite_id] = session[:jobsite_id]
    if @job.update_attributes(params[:job])
      session_job_id
        redirect_to jobs_path, :notice => t('jobs.update.notice1')
     else
      render :action => "edit"
    end
  end
  
  
  def destroy
    @job = Job.find(params[:id])
    if @job.destroy
      #destroy the session
      session[:job_id] = nil
      flash[:notice] = t('jobs.destroy.notice')
    else
      flash[:error] =  t('jobs.destroy.error')
    end
    redirect_to jobs_url
  end
  

  def session_job_id
    @job.id ? session[:job_id] = @job.id : ''
  end

  
  def find_id_by_role
    @tech_role = current_login.roles.find_by_roll("Tech")
    @tech_role ? @tech_users = current_login.users.find_all_by_role_id(@tech_role.id) : @tech_users = nil

    @sales_role = current_login.roles.find_by_roll("Sales")
    @sales_role ? @sales_users = current_login.users.find_all_by_role_id(@sales_role.id) : @sales_users = nil
  end

  
  
  def close_job
    @jobs = search_by_session(current_login.jobs.search(params[:search]).where(:status => "open")).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    @job = Job.find(params[:id])
    @job.update_attribute(:status, "closed")
    flash[:notice] = t('jobs.close_job.notice')
    respond_to do |format|
      format.js
    end
  end
    
  
  def invoice_job
    @jobs = search_by_session(current_login.jobs.search(params[:search]).where(:status => "open")).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    push_invoice_and_send_to_qbo
      rescue OAuth::Problem
      flash[:alert] = "OAuth::Problem - token_rejected. Please Reconnect to QBO"
    respond_to do |format|
      format.js
    end
  end
  
  
  def invoice_and_pay
    @job = Job.find(params[:id])
    @total = 0
    if current_login.inventories.exists?(:job_id => @job.id) || current_login.jobtimes.exists?(:job_id => @job.id)
      @inventory = current_login.inventories.find_all_by_job_id(params[:id])
      @inventory.each do |inventory|
        @total = @total + (inventory.qty.to_f * inventory.unit_price.to_i)
      end
      @jobtime = current_login.jobtimes.find_all_by_job_id(params[:id])
      @jobtime.each do |jobtime|
        @total = @total + (jobtime.price.to_f)
      end
      @job.total = @total
      @job.update_attributes(:total => @job.total)
    end
    @payment = Payment.new
  end
  
  
  def process_invoice
    @payment = Payment.new(params[:payment])
    @payment.company_id = current_login.id
    @payment.job_id = @job.id
    @amount = params[:payment][:amount]
    @payment.balance = @job.total.to_i - @amount.to_i
    if @payment.save
      #push_invoice_to_quickbook
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_login.access_token, current_login.access_secret)
    
      customer_service = Quickeebooks::Online::Service::Customer.new
      customer_service.access_token = oauth_client
      customer_service.realm_id = current_login.realm_id
    
      #push payment to qbo
      payment_service =Quickeebooks::Online::Service::Payment.new 
      payment_service.access_token= oauth_client
		  payment_service.realm_id= current_login.realm_id
      
      #push invoice to qbo
      invoice_service = Quickeebooks::Online::Service::Invoice.new
      invoice_service.access_token = oauth_client
      invoice_service.realm_id = current_login.realm_id
      
      if current_company.present?
        if current_company.access_token.present? && current_company.access_secret.present? && current_company.realm_id.present?
          @job = current_login.jobs.find(params[:id])
          @customer = current_login.customers.find(@job.customer_id)
          @payment = Payment.find_by_job_id(@job.id)
            
          
          #pushing invoice
          
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
            
            #payment model
            payment = Quickeebooks::Online::Model::Payment.new
            
            if current_login.payments.exists?(:job_id => @job.id)
              @pay = Payment.last      
              #header_parts
              payment_header = Quickeebooks::Online::Model::PaymentHeader.new
            
              customer = customer_service.fetch_by_id(@customer.quickbook_customer_id)
              if customer.present?
                payment_header.customer_id = customer.id
                payment_header.customer_name = customer.name
              end
            
              payment_header.doc_number = @job.reference_no
              payment_header.status = @job.summary
              payment_header.total_amount = @amount
              payment_header.payment_method_name = @pay.payment_type
          
              payment.header = payment_header
            
              payment_service.create(payment)
            
            
              @job.update_attributes(:status => 'invoiced')
              send_invoice_qbo
              flash[:notice] = "Job invoiced successfully; QuickBooks Transaction  ##{@job.reference_no}"
            end
          end
        end
        #push_invoice_and_send_to_qbo
        redirect_to jobs_path
      end
    end
  end
 
  
  def print_invoice
    @job = Job.find(params[:id])
    @payment = Payment.find_by_job_id(params[:id])
    render :pdf => "jobs/print_invoice"
  end
  
  
  def email_invoice
    @job = Job.find(params[:id])
    @payment = Payment.find_by_job_id(params[:id])
    push_invoice_to_quickbook
    @company = Company.find(current_login.id)
    if @job.contact_id.present?
      CompanyMailer.email_invoice(@company,@job).deliver
    else
      flash[:alert] = "Please select contact for this job."
    end
    rescue OAuth::Problem
      flash[:alert] = "OAuth::Problem - token_rejected. Please Reconnect to QBO"
    respond_to do |format|
      format.js
    end
  end
  
  def convert_to_invoice
    @job = Job.find(params[:id])
    @total = 0
    if current_login.inventories.exists?(:job_id => @job.id) || current_login.jobtimes.exists?(:job_id => @job.id)
      @inventory = current_login.inventories.find_all_by_job_id(params[:id])
      @inventory.each do |inventory|
        @total = @total + (inventory.qty.to_f * inventory.unit_price.to_i)
      end
      @jobtime = current_login.jobtimes.find_all_by_job_id(params[:id])
      @jobtime.each do |jobtime|
        @total = @total + (jobtime.price.to_f)
      end
      @job.total = @total
      @job.update_attributes(:total => @job.total)
    end
    if @job.contact_id.present?
      @contact = Contact.find(@job.contact_id)
    end
  end
  
  def email_jobdetails
    @job = Job.find(params[:id])
    @company = Company.find(current_login.id)
    if @job.contact_id.present?
      CompanyMailer.send_job_details(@company,@job).deliver
      redirect_to jobs_path, :notice => "Email has been sent."
    else
      redirect_to jobs_path, :alert => "Please select contact for this job."
    end
  end
  
  def send_invoice
    @job = Job.find(params[:id])
    @total = 0
    if current_login.inventories.exists?(:job_id => @job.id) || current_login.jobtimes.exists?(:job_id => @job.id)
      @inventory = current_login.inventories.find_all_by_job_id(params[:id])
      @inventory.each do |inventory|
        @total = @total + (inventory.qty.to_f * inventory.unit_price.to_i)
      end
      @jobtime = current_login.jobtimes.find_all_by_job_id(params[:id])
      @jobtime.each do |jobtime|
        @total = @total + (jobtime.price.to_f)
      end
      @job.total = @total
      @job.update_attributes(:total => @job.total)
    end
    push_invoice_to_quickbook
    @company = Company.find(current_login.id)
    if @job.contact_id.present?
      CompanyMailer.send_invoice(@company,@job).deliver
      flash[:notice]= "Email has been sent successfully."
    else
      flash[:alert]= "Please select contact for this job."
    end
    rescue OAuth::Problem
      flash[:alert] = "OAuth::Problem - token_rejected. Please Reconnect to QBO"
    respond_to do |format|
      format.js
    end
  end
  

  def print_invoice_pay
    @job = Job.find(params[:id])
    render :pdf => "jobs/print_invoice_pay"
  end
  
  def send_invoice_qbo
    @job = Job.find(params[:id])
    @total = 0
    if current_login.inventories.exists?(:job_id => @job.id) || current_login.jobtimes.exists?(:job_id => @job.id)
      @inventory = current_login.inventories.find_all_by_job_id(params[:id])
      @inventory.each do |inventory|
        @total = @total + (inventory.qty.to_f * inventory.unit_price.to_i)
      end
      @jobtime = current_login.jobtimes.find_all_by_job_id(params[:id])
      @jobtime.each do |jobtime|
        @total = @total + (jobtime.price.to_f)
      end
      @job.total = @total
      @job.update_attributes(:total => @job.total)
    end
    @payment = Payment.find_by_job_id(params[:id])
    @company = Company.find(current_login.id)
    if @job.contact_id.present?
      CompanyMailer.send_invoice(@company,@job).deliver
    end  
  end
  
  def close_job_invoice
    @job = Job.find(params[:id])
    @job.update_attribute(:status, "closed")
    flash[:notice]="Job was closed successfully."
    redirect_to jobs_path
  end
  
  
  def change_customer
    @job = Job.find(params[:id])
  end
  
  
  def change_customer_jobsite
    @job = Job.find(params[:id])
    @customer = session[:customer_id]
    @jobsites = params[:jobsite_id]
    @job.update_attributes(:customer_id => @customer, :jobsite_id => @jobsites)
    flash[:notice]= "Customer and Jobsite changed successfully for job"
    redirect_to jobs_path
  end
end
