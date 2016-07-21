class RolesController < ApplicationController
  before_filter :is_login?
  before_filter :access_role?
  before_filter :get_roles, :only => ["create", "edit", "update", "index"]
  #before_filter :trial_period_expired?
  
  def index
    @role = Role.new
  end
  
  def new
    @role = Role.new
  end

  def edit
    @role = Role.find(params[:id])
    render
  end

  def create
    @role = current_login.roles.new(params[:role])
    @role.save
    respond_to do |format|
      format.js
    end  
  end

  def update
    @role = Role.find(params[:id])
    @update_status = false

    if @role.update_attributes(params[:role])
      @update_status = true
    else
      @update_status = false
    end
    respond_to do |format|
      format.js
    end
  end


  def destroy
    @role = Role.find(params[:id])

    @role.destroy
    respond_to do |format|
      format.js
    end
  end

  private
  def get_roles
    @roles = current_login.roles.order("created_at desc")
  end
end
