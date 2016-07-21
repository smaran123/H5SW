class InventoriesController < ApplicationController

  before_filter :is_login?
  #before_filter :trial_period_expired?

  respond_to :html,:js
  before_filter :session_types
  
  def index
   @inventories = current_login.inventories.order("created_at").find_all_by_job_id(session[:job_id])
  end

  def new
    @inventory = Inventory.new
  end

  def edit
    @inventory = Inventory.find(params[:id])
  end

  def create
    @inventory = Inventory.new(params[:inventory])
    @inventory.company_id = current_login.id
    
    if @inventory.save
      flash[:notice]= t('inventories.create.notice')
      redirect_to inventories_path
    else
      render :action => "new"
    end
  end

  def update
    @inventory = Inventory.find(params[:id])
    @inventory.subtotal = (params[:inventory][:qty].to_f*@inventory.unit_price.to_i) if params[:inventory][:qty].present?
    if @inventory.update_attributes(params[:inventory])
      @inventories = current_login.inventories.order("created_at").find_all_by_job_id(session[:job_id])
      respond_with @inventory
    else
      render :action => "edit"
    end
  end

  def destroy
    @inventory = Inventory.find(params[:id])
    if @inventory.destroy
      flash[:notice] = t('inventories.destroy.notice')
    else
      flash[:error] = t('inventories.destroy.error')
    end
    redirect_to inventories_url
  end
end
