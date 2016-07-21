class Api::RegistrationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  #create company using api call
  # curl -X POST -d 'type=Company&company[name]=smo&company[phone_number]=8845786963&company[email]=h5sw@gmail.com&company[password]=123123123&company[password_confirmation]=123123123' http://localhost:3000/api/sign_up.json
  def create
      company = Company.new(params[:company])
      if company.save
        render :json=> company.as_json(:auth_token=>company.authentication_token, :email=>company.email), :status=>201
        return
      else
        warden.custom_failure!
        render :json=> company.errors, :status=>422
      end
  end
  
#curl -X POST -d 'user[accounting_name]=ABC&user[accounting_type]=customer&user[role_id]=61&user[email]=sowmya@gmail.com&user[name]=sandhya&user[smo_user]=true&user[language]=English&user[time_zone]= Mexico city&user[password]=123123123&user[company_id]=10' http://localhost:3000/api/users/sign_up.json
  def users_create
     user = User.new(params[:user])
      if user.save
        render :json=> user.as_json(:auth_token=>user.authentication_token, :email=>user.email), :status=>201
        return
      else
        warden.custom_failure!
        render :json=> user.errors, :status=>422
      end 
  end
end
