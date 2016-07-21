class BusinessesController < ApplicationController
  before_filter :is_login?
  #before_filter :trial_period_expired?
  
  def index
    @businesses = current_login.businesses.paginate(:per_page => 10,:page => params[:page]).order('created_at desc')
  end
  
  def new
    @business = Business.new
  end
  
  def create
    @business = Business.new(params[:business])
    @business.company_id = current_login.id
    
    if @business.save
      flash[:notice]= t('businesses.create.notice')
      redirect_to settings_path
    else
      render :action => "new"
    end
  end
  
  def edit
    @business = Business.find(params[:id])
  end
  
  def update
    @business = Business.find(params[:id])
    if @business.update_attributes(params[:business])
      redirect_to settings_path, :notice => t('businesses.update.notice')
    else
      render :action => "edit"
    end
  end
  
  def show
    @business = Business.find(params[:id])
    redirect_to settings_path
  end
  
  def destroy
   @business = Business.find(params[:id])
    if @business.destroy
      flash[:notice] = t('businesses.destroy.notice')
    else
      flash[:error] = t('businesses.destroy.error')
    end
    redirect_to settings_path
  end
end
 