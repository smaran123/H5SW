class Api::JobsitesController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token
  
  #curl -X GET -d 'customer_id=64&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobsites.json
  #curl -X GET -d 'customer_id=64&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobsites.xml
  def index
   @jobsites = Jobsite.find_all_by_customer_id(params[:customer_id])
    respond_to do |format|
      format.xml{ render :xml => @jobsites }
      format.json { render :json => @jobsites }
    end
  end
  
  #curl -X POST -d 'jobsite[name]=pizza at bommanahalli&jobsite[city]=bangalore&jobsite[state]=karnataka&jobsite[zip]=560068&jobsite[customer_id]=64&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobsites.json
  #curl -X POST -d 'jobsite[name]=pizza at bommanahalli&jobsite[city]=bangalore&jobsite[state]=karnataka&jobsite[zip]=560068&jobsite[customer_id]=64&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobsites.xml
  def create
    @jobsite = Jobsite.new(params[:jobsite])
    if @jobsite.save
      response_message = {:message => "Jobsite was created successfully.", :jobsite => @jobsite }
    else
      response_message = {:message => "Jobsite creation failed.Please try again"}
    end
    respond_to do |format|
      format.xml{ render :xml => response_message }
      format.json{ render :json => response_message }
    end
  end
  
  #curl -X PUT -d 'jobsite[name]=pizza at Bommanahalli&jobsite[city]=bangalore&jobsite[state]=karnataka&jobsite[zip]=560068&jobsite[customer_id]=64&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobsites/id.json
  #curl -X PUT -d 'jobsite[name]=pizza at Bommanahalli&jobsite[city]=bangalore&jobsite[state]=karnataka&jobsite[zip]=560068&jobsite[customer_id]=64&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobsites/id.xml
  def update
    @jobsite = Jobsite.find(params[:id])
    if @jobsite.update_attributes(params[:jobsite])
      response_message = {:message => "Jobsite was updated successfully.", :jobsite => @jobsite }
    else
      response_message = {:message => "Jobsite updation failed.Please try again"}
    end
    respond_to do |format|
      format.xml { render :xml => response_message}
      format.json { render :json => response_message }
    end
  end
  
  #curl -X DELETE -d 'api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobsites/id.json
  #curl -X DELETE -d 'api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobsites/id.xml
  def destroy
    @jobsite = Jobsite.find(params[:id])
    if @jobsite.destroy
      response_message = {:message => "Jobsite was deleted Successfully.", :jobsite => @jobsite }
    else
      response_message = {:message => "Jobsite deletion failed.Please try again."}
    end
    respond_to do |format|
      format.xml{ render :xml => response_message }
      format.json{ render :json => response_message }
    end
  end
end
