class RecurringsController < ApplicationController
  before_filter :is_login?
  before_filter :session_types
  
  def index
    @recurrings = current_login.recurrings.paginate(:page => params[:page], :per_page => 10).order('created_at asc')
  end
  
  def new
    @recurring = Recurring.new
  end
  
  def create
   @recurring = Recurring.new(params[:recurring])
    @recurring.company_id = current_login.id
    if params[:recurring][:interval] == "daily"
    @recurring.every = params[:daily]
    @recurring.on = ""
    elsif params[:recurring][:interval]  == "weekly"
    @recurring.every = params[:weekly]
    @recurring.on = params[:weekly1]
    elsif params[:recurring][:interval] == "monthly"
      @recurring.every = params[:monthly1]
      @recurring.on = params[:monthly]
    else
      @recurring.every = params[:year]
      @recurring.on = params[:year1]
    end
    @recurring.company_id = current_login.id
    @recurring.job_id = session[:job_id]
    @recurring.customer_id = session[:customer_id]
    @recurring.jobsite_id = session[:jobsite_id]
    if @recurring.save
      flash[:notice]="Recurring order created successfully"
      redirect_to recurrings_path
    else
      render :action => :new
    end
  end
  
  def edit
    @recurring = Recurring.find(params[:id])
  end
  
  def update
    @recurring = Recurring.find(params[:id])
    if params[:recurring][:interval] == "daily"
      @recurring.every = params[:daily]
      @recurring.on = ""
    elsif params[:recurring][:interval]  == "weekly"
      @recurring.every = params[:weekly]
      @recurring.on = params[:weekly1]
    elsif params[:recurring][:interval] == "monthly"
        @recurring.every = params[:monthly1]
        @recurring.on = params[:monthly]
    else
        @recurring.every = params[:year]
        @recurring.on = params[:year1]
    end 
    if @recurring.update_attributes(params[:recurring])
      flash[:notice]= "Recurring order updated successfully."
      redirect_to recurrings_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    @recurring = Recurring.find(params[:id])
    if @recurring.destroy
      flash[:notice]= "Recurring order deleted successfully."
      redirect_to recurrings_path
    end
  end
end
