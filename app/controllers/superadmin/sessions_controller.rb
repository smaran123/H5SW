class Superadmin::SessionsController < Devise::SessionsController
  
  def new
    render :layout => 'superadmin'
  end
  
  def create
    resource = warden.authenticate!(:scope => resource)
    redirect_to superadmin_dashboards_path
    flash[:notice] = "Signed in successfully."
  end
  
  def destroy
    signed_in = signed_in?(resource_name)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    flash[:notice] = "Logout Sucessfully."
    redirect_to "/"
  end
end

