class ContactsController < ApplicationController
   
  before_filter :is_login?
  before_filter :get_contacts, :only => ["create", "edit", "update"]
  before_filter :access_role?
  before_filter :session_types
  #before_filter :trial_period_expired?
  # GET /contacts
  def index
   @contacts = search_by_session(current_login.contacts.search(params[:search])).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
  end

  # GET /contacts/1
  def show
    @contact = Contact.find(params[:id])
  end

  # GET /contacts/new
  def new    
    @contacts = search_by_session(current_login.contacts.search(params[:search])).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
    @contact = Contact.find(params[:id])
  end

  # POST /contacts
  def create
    @contact = Contact.new(params[:contact])
    @contact.company_id = current_login.id

    @mobile1 = params[:contact][:mobile1]
    @mobile2 = params[:contact][:mobile2]
    @mobile3 = params[:contact][:mobile3]
    @mobile4 = params[:contact][:mobile4]
    @business1 = params[:contact][:business1]
    @business2 = params[:contact][:business2]
    @business3 = params[:contact][:business3]
    @business4 = params[:contact][:business4]
    @contact.save
    respond_to do |format|
      format.js
    end
  end

  # PUT /contacts/1
  def update
    @contact = Contact.find(params[:id])
    @update_status = false
    @mobile1 = params[:contact][:mobile1]
    @mobile2 = params[:contact][:mobile2]
    @mobile3 = params[:contact][:mobile3]
    @mobile4 = params[:contact][:mobile4]
    @business1 = params[:contact][:business1]
    @business2 = params[:contact][:business2]
    @business3 = params[:contact][:business3]
    @business4 = params[:contact][:business4]
    if @contact.update_attributes(params[:contact])     
      @update_status = true
    else
      @update_status = false
    end
    respond_to do |format|
      format.js
    end
  end

  # DELETE /contacts/1
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.js
    end
  end

  def ajax_show
    @contact = Contact.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  private
  def get_contacts
     @contacts = search_by_session(current_login.contacts).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
   end
 end
