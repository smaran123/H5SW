class Superadmin::DashboardsController < ApplicationController
  before_filter :is_superadmin?
  
  def index
    @companies = Company.order('created_at desc')
    respond_to do |format|
      format.html
      format.csv { send_data @companies.to_csv }
      format.xls 
    end
  end
  
  def users_list
    @users = User.order('created_at desc')
    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv }
      format.xls 
    end
  end
end
