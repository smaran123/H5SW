class Api::BaseController < ApplicationController
  respond_to :json, :xml
  
  before_filter :authenticate_user
   
  private
  def authenticate_user
    @current_company = Company.find_by_authentication_token(params[:api_key])
    unless @current_company
      respond_to do |format|
        format.xml{ render :xml => {:error => "Api key is invalid." }}
        format.json{ render :json => { :error => "Api key is invalid." }}
      end
    end
  end
  
  def current_company
    @current_company
  end
  
end