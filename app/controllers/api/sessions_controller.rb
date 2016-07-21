class Api::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token
  
  #curl -X POST -d 'company[email]=star@gmail.com&company[password]=123123123' http://localhost:3000/api/sign_in.json
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    sign_in(resource_name, resource)
    respond_to do |format|
      format.json {
        return render :json => { :authentication_token => resource.authentication_token, :company_id => resource.id }, :status => :created
      }
    end
  end
  
  #should log out the user, changing the authentication token.
  #curl -X DELETE -d 'api_key=zjaskzP9sZGpvZ3gkNdM' http://localhost:3000/api/sign_out.json
  def destroy
    # expire auth token
   
    @company=Company.where(:authentication_token=>params[:api_key]).first
    @company.reset_authentication_token!
    render :json => { :message => ["Session deleted."] },  :success => true, :status => :ok
  end

end
