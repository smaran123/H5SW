class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  skip_before_filter :verify_authenticity_token, :only => [:intuit]
  
  def intuit
    @company = Company.find_for_open_id(request.env["omniauth.auth"], current_company)
    
    if @company.persisted?
      session[:single_sign_on] = true
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Intuit"
      sign_in_and_redirect @company, :event => :authentication
    else
      session[:single_sign_on] = true
      session["devise.intuit_data"] = request.env["omniauth.auth"]
      redirect_to new_company_registration_url
    end
  end
end
