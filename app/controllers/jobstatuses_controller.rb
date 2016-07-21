class JobstatusesController < ApplicationController
  before_filter :is_login?
  #before_filter :trial_period_expired?
  
  def index
    
  end
  def new
    @jobstatus = Jobstatus.new
  end
  
  def create
    @jobstatus = Jobstatus.new(params[:jobstatus])
    @jobstatus.company_id = current_login.id
    if @jobstatus.save
      flash[:notice] = t('jobstatuses.create.notice')
      redirect_to settings_path
    else
      render :action => "new"
    end
  end
  
  def edit
    @jobstatus = Jobstatus.find(params[:id])
  end
  
  def update
    @jobstatus = Jobstatus.find(params[:id])
    if @jobstatus.update_attributes(params[:jobstatus])
      redirect_to settings_path, :notice => t('jobstatuses.update.notice')
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @jobstatus = Jobstatus.find(params[:id])
    if @jobstatus.destroy
      flash[:notice] = t('jobstatuses.destroy.notice')
    else
      flash[:error]= t('jobstatuses.destroy.error')
    end
    redirect_to settings_path
  end
end
