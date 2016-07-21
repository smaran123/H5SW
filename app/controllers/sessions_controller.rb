class SessionsController < Devise::SessionsController
  before_filter :dis_quickbooks, :only => :destroy

  def destroy
    p "Trigger: quickbooks must disconnect if this message appears"
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    flash[:notice] = "Logout Successfully."
    redirect_to "/"
  end
  
  
  private
  
  def dis_quickbooks
    if signed_in?
      # find connected services
      set_qb_service('AccessToken')   
      # disconnect connected services
      result = @service.disconnect
      # send the status result
      if result.error_code == '270'
        msg = 'Disconnect failed as OAuth token is invalid. Try connecting again.'
      else
        msg = 'Successfully disconnected from QuickBooks'
      end
      current_company.update_attributes({
          :access_token => nil,
          :access_secret => nil,
          :realm_id => nil
        })
    end
  end
end
