class Api::ContactsController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token

  # list of contacts
  # curl -X GET -d 'api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/contacts.json
  def index
    @contacts = current_company.contacts
    respond_to do |format|
      format.xml { render :xml => @contacts }
      format.json { render :json => @contacts }
    end
  end
  
  # create a contact
  # curl -X POST -d 'contact[business]=XXXX&contact[email]=john@gmail.com&contact[mobile]=XXXX&contact[name]=XXXX&contact[role]=XXXX&contact[twitter]=@john&contact[jobsite_id]=XXXX&contact[customer_id]=XXXX&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/contacts.json
  def create
    @contact = Contact.new(params[:contact])
    @contact.company_id = current_company.id

    if @contact.save
      response_message = {:message => "Contact created successfully.", :contact => @contact}
    else
      response_message = {:message => "Contact creation failed. Please try again!"}
    end
    
    respond_to do |format|
      format.xml  { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # update contact
  # curl -X PUT -d 'contact[business]=XXX-XXX-XXXX-XXXX&contact[email]=XXXX&contact[mobile]=XXX-XXX-XXXX-XXXX&contact[name]=XXXX&contact[role]=XXXX&contact[twitter]=XXXX&contact[jobsite_id]=XXXX&contact[customer_id]=XXXX&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/contacts/:id.json
  def update
    @contact = Contact.find(params[:id])
    if @contact.update_attributes(params[:contact])
      response_message = {:message => "Contact updated successfully.", :contact => @contact}
    else
      response_message = {:message => "Contact updation failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # delete contact
  # curl -X DELETE -d 'api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/contacts/id.json
  def destroy
    @contact = Contact.find(params[:id])
    if @contact.destroy
      response_message = {:message => "Contact deleted successfully.", :contact => @contact}
    else
      response_message = {:message => "Contact deletion failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end
  
end
