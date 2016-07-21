class DashboardsController < ApplicationController
  #before_filter :trial_period_expired?
  before_filter :is_login?
  
  def index
    @json = Jobsite.where(:customer_id => current_login.customers.collect(&:id)).all.to_gmaps4rails
    #@jobs = Job.where(:status => 'closed').paginate(:per_page => 10, :page => params[:page])
  end
end


#
#if Jobsite.where(:customer_id => current_login.customers.collect(&:id)).present?
#  @json = Jobsite.where(:customer_id => current_login.customers.collect(&:id)).all.to_gmaps4rails
#else
#  @json = Jobsite.where(:name => "Default Map").to_gmaps4rails
#end