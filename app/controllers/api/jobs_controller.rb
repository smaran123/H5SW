class Api::JobsController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token

  # List of Jobs
  # curl -X GET -d 'api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/jobs.json
  def index
   if params[:my_job] == 'all jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search])).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    elsif params[:my_job]== 'unassigned jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search]).where(:assigned_to => "NULL")).paginate(:per_page => 10, :page => params[:page])
    elsif params[:my_job] == 'my jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search]).where("status='open' AND assigned_to != 'NULL'")).paginate(:per_page => 10, :page => params[:page])
    elsif params[:my_job] == 'closed jobs'
      @jobs = search_by_session(current_login.jobs.search(params[:search]).where(:status => "closed")).paginate(:per_page => 10, :page => params[:page])
    else
      @jobs = search_by_session(current_login.jobs.search(params[:search])).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    end

    respond_to do |format|
      format.xml {render :xml => @jobs}
      format.json {render :json => @jobs}
    end
  end

  # create jobs
  # curl -X POST -d 'job[reference_no]=XXXX&job[due_date(1i)]=year&job[due_date(2i)]=month&job[due_date(3i)]=day&job[due_date(4i)]=HH&job[due_date(5i)]=MM&job[class_type]=XXXX&job[assigned_to]=XXXX&job[status]=XXXX&job[sales_person]=XXXX&job[summary]=XXXX&job[contact_id]=XXXX&job[name]=XXXX&job[signature]=XXXX&job[customer_id]=XXXX&job[jobsite_id]=XXXX&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/jobs.json
  def create
    @job = Job.new(params[:job])
    @job.company_id = current_company.id

    if @job.save
      response_message = {:message => "Job created successfully.", :job => @job}
    else
      response_message = {:message => "Job creation failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message}
      format.json { render :json => response_message }
    end
  end

  # update jobs
  # curl -X PUT -d 'job[reference_no]=XXXX&job[due_date(1i)]=year&job[due_date(2i)]=month&job[due_date(3i)]=day&job[due_date(4i)]=HH&job[due_date(5i)]=MM&job[class_type]=XXXX&job[assigned_to]=XXXX&job[status]=XXXX&job[sales_person]=XXXX&job[summary]=XXXX&job[contact_id]=XXXX&job[name]=XXXX&job[signature]=XXXX&job[customer_id]=XXXX&job[jobsite_id]=XXXX&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/jobs/id.json
  def update
    @job = Job.find(params[:id])
    if @job.update_attributes(params[:job])
      response_message = {:message => "Job updated successfully.", :job => @job}
    else
      response_message = {:message => "Job updation failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # delete jobs
  # curl -X DELETE -d 'api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/jobs/:id.json
  def destroy
    @job = Job.find(params[:id])
    if @job.destroy
      response_message = {:message => "Job deleted successfully.", :job => @job}
    else
      response_message = {:message => "Job deletion failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # close the job (make the status of the job as closed accrding to id)
  # curl -X PUT -d 'api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/jobs/id/close_job.json
  def close_job
    @job = Job.find(params[:id])
    if @job.update_attribute(:status, "closed")
      response_message = {:message => "This job is closed successfully.", :job => @job}
    else
      response_message = {:message => "Failed to close this job. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end
end
