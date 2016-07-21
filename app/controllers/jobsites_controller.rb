class JobsitesController < ApplicationController 
  before_filter :is_login?
  before_filter :gmap_json, :only => ["edit"]
  #before_filter :trial_period_expired?

  def index
    @jobsites = search_by_customer_id(Jobsite.search(params[:search])).where(:customer_id => current_login.customers.collect(&:id)).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
  end

  def new
    params[:cust_id] ? session[:customer_id] = params[:cust_id] : ' '
    params[:cust_id] ? session[:jobsite_id] = nil : ' '

    @jobsite = Jobsite.new
    session[:customer_id] ? @customer_id = session[:customer_id] : ' '
  end


  def show
    @jobsite = Jobsite.find(params[:id])
  end


  def edit
    @jobsite = Jobsite.find(params[:id])
  end

  def create
    
    @jobsite = Jobsite.new(params[:jobsite])
    
    if @jobsite.save
#      if current_company.present?
#        if current_company.access_token.present? && current_company.access_secret.present? && current_company.realm_id.present?
#          push_jobsite_to_quickbook(@jobsite)
#          flash[:notice] = t('jobsites.create.noticeqb')
#        else
#          flash[:alert] = t('jobsites.create.alert')
#          flash[:notice] = t('jobsites.create.notice')
#        end
#      else
#        flash[:notice] = t('jobsites.create.notice1')
#      end
       flash[:notice] = "Jobsite was created successfully."
      redirect_to jobsites_path
    else
      render :action => "new"
    end
  end

  # PUT /customers/1
  def update
    @jobsite = Jobsite.find(params[:id])
    if @jobsite.update_attributes(params[:jobsite])
#      if current_company.present?
#        #        if current_company.access_token.present? && current_company.access_secret.present? && current_company.realm_id.present?
#        #          update_jobsite_to_quickbook(@jobsite)
#        #          flash[:notice] = "Jobsite was successfully updated in SMO and QBO    ."
#        #        else
#        #          flash[:alert] = "Warning: You are not connected with QuickBooks."
#        #          flash[:notice] = "Jobsite was successfully updated."
#        #        end
#        flash[:notice] = t('jobsites.update.notice')
#      else
#        flash[:notice] = t('jobsites.update.notice1')
#      end
      flash[:notice] = "Jobsite was updated successfully."
      redirect_to jobsites_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @jobsite = Jobsite.find(params[:jobsite])
    if @jobsite.destroy
      flash[:notice] = "Jobsite was successfully deleted"
    else
      flash[:error] = "Jobsite deletion failed"
    end
    redirect_to jobsites_url
  end

  # action for displaying dynamic select options
  def ajax_show
    session[:customer_id] = params[:id]
    session[:jobsite_id] = "All"
    @jobsites = Jobsite.find_all_by_customer_id(session[:customer_id])
    @edit = params[:edit]
    render
  end

  #action for storing the selected id to session
  def get_id
    session[:jobsite_id] = params[:id]
    render :nothing => true
  end


  def show_jobsite
    session[:customer_id] = params[:id]
    session[:jobsite_id] = "All"
    @customer = Customer.find(session[:customer_id])
    @jobsites = Jobsite.find_all_by_customer_id(session[:customer_id])
  end

  
  def get_jobsite
    @customer = Customer.find_by_id(session[:customer_id])
    session[:jobsite_id] = params[:id]
    @jobsite = Jobsite.find_by_id(session[:jobsite_id])
    respond_to do |format|
      format.js
    end
  end


  #push jobsite into QuickBooks as job
  def push_jobsite_to_quickbook(jobsites)
    #push data to QuickBooks
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_company.access_token, current_company.access_secret)

    jobsite_service = Quickeebooks::Online::Service::Job.new
    jobsite_service.access_token = oauth_client
    jobsite_service.realm_id = current_company.realm_id
    
    
    jobsite = Quickeebooks::Online::Model::Job.new

    # find quickbook_customer_id
    @parent_customer = current_company.customers.find(@jobsite.customer_id)
    
    # parent customer information
    job_customer = Quickeebooks::Online::Model::Id.new
    job_customer.value = @parent_customer.quickbook_customer_id #customer.id       # @parent_customer.quickbook_customer_id.to_i
    jobsite.customer_name = @parent_customer.company_name

    jobsite.customer_id = job_customer
    # end of parent customer information
    
    jobsite.name = @jobsite.name

    address = Quickeebooks::Online::Model::Address.new
    address.city = @jobsite.city
    address.country_sub_division_code = @jobsite.state
    address.postal_code = @jobsite.zip
    jobsite.addresses = [address]

    jobsite_service.create(jobsite)
  end


  # update jobsite to QuickBooks
  def update_jobsite_to_quickbook(jobsite)
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_company.access_token, current_company.access_secret)

    jobsite_service = Quickeebooks::Online::Service::Job.new
    jobsite_service.access_token = oauth_client
    jobsite_service.realm_id = current_company.realm_id

    @parent_customer = @jobsite.customer.present? ? @jobsite.customer : nil

    unless @parent_customer.quickbook_customer_id.present? || @parent_customer.quickbook_customer_id != nil
      flash[:error] = t('jobsites.update_jobsite_to_quickbook.error')
    else
      # check whether jobsite is already pushed to QuickBooks or not. if not push it otherwise
      filters = []
      filters << Quickeebooks::Online::Service::Filter.new(:text, :field => 'name', :value => @jobsite.name)
      jobsite = jobsite_service.list(filters)
      jobsite = jobsite_service.fetch_by_id(jobsite.id)

      unless jobsite.present?
        push_jobsite_to_quickbook(@jobsite)
      else
        # update the jobsite
        job_customer = Quickeebooks::Online::Model::Id.new
        job_customer.value = @parent_customer.quickbook_customer_id #customer.id       # @parent_customer.quickbook_customer_id.to_i
        jobsite.customer_name = @parent_customer.company_name

        jobsite.customer_id = job_customer
    
        jobsite.name = @jobsite.name

        unless jobsite.addresses.present?
          # create new address
          address = Quickeebooks::Online::Model::Address.new
          address.city = @jobsite.city
          address.country_sub_division_code = @jobsite.state
          address.postal_code = @jobsite.zip
          jobsite.addresses = [address]
        else
          # update existing address
          jobsite.addresses.first.city = @jobsite.city
          jobsite.addresses.first.country_sub_division_code = @jobsite.state
          jobsite.addresses.first.postal_code = @jobsite.zip
        end

        jobsite_service.update(jobsite)
      end
      # update that jobsite
    end
  end
end



