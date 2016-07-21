class JobsitesController < ApplicationController

  

  def index
    @jobsites = Jobsite.all
  end

  def new
    @jobsite = Jobsite.new
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
      flash[:notice] = "Jobsite was successfully created."
      redirect_to jobsites_path
    else
      render :action => "new"
    end
  end

  # PUT /customers/1
  def update
    @jobsite = Jobsite.find(params[:id])
    if @jobsite.update_attributes(params[:jobsite])
      flash[:notice] = "Jobsite was successfully updated."
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
    @jobsites = Jobsite.find_all_by_customer_id(session[:customer_id])
    session[:customer_id] = params[:id]
    respond_to do |format|
      format.js{render :partial =>'jobsites'}
    end
  end

  #action for storing the selected id to session
  def get_id
    session[:jobsite_id] = params[:id]
    #puts params[:id],session[:jobsite_id]
    render :nothing => true
  end
end
