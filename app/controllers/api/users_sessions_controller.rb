class Api::UsersSessionsController < Devise::SessionsController
  #curl -X POST -d 'user[email]=star@gmail.com&user[password]=123123123' http://localhost:3000/api/users/sign_in.json
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    sign_in(resource_name, resource)
    respond_to do |format|
      format.json {
        return render :json => { :authentication_token => resource.authentication_token, :user_id => resource.id }, :status => :created
      }
    end
  end
  
  #curl -X DELETE -d 'api_key=7e9s1B3CtiHUdQzssb5R' http://localhost:3000/api/users/sign_out.json
  def destroy
    @user=User.where(:authentication_token=>params[:api_key]).first
    @user.reset_authentication_token!
    render :json => { :message => ["Session deleted."] },  :success => true, :status => :ok
  end
end
