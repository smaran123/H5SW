class Superadmin::CompaniesController < ApplicationController
  before_filter :is_superadmin?
   
  def destroy
    @company = Company.find(params[:id])
    if @company.destroy
      flash[:notice] = "Company was deleted successfully."
    else
      flash[:error]= "Company deletion failed.Please try again."
    end
    redirect_to superadmin_dashboards_path
  end
  
  def inactivate_company
    @company = Company.find(params[:id])
    @company.update_attributes(:status => "Inactive")
    flash[:notice]= "Company was inactivated successfully."
    respond_to do |format|
      format.js
    end
  end
  
  def activate_company
    @company = Company.find(params[:id])
    @company.update_attributes(:status => "paid")
    flash[:notice]= "Company was activated successfully."
    respond_to do |format|
      format.js
    end
  end
end
