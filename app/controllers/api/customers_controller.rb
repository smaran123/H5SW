class Api::CustomersController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token
  
  #curl -X GET -d 'api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/customers.json
  def index
     @customers = current_company.customers.all
     respond_to do |format|
       format.xml{ render :xml=> @customers }
       format.json{ render :json => @customers }
     end
   end
   
   #curl -X POST -d 'customer[types]=customer&customer[company_name]=airtel&customer[address1]=Jayanagar&customer[address2]=Bangalore&customer[city]=Bangalore&customer[state]=Karnataka&customer[zip]=560011&customer[contact_id]=23&customer[account]=54154&customer[phone]=999-885-8844&customer[website]=h5sw.com&customer[business_type]=commercial&customer[terms_client]=Net 10&customer[status]=Active&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/customers.json 
   #curl -X POST -d 'customer[types]=customer&customer[company_name]=airtel&customer[address1]=Jayanagar&customer[address2]=Bangalore&customer[city]=Bangalore&customer[state]=Karnataka&customer[zip]=560011&customer[contact_id]=23&customer[account]=54154&customer[phone]=999-885-8844&customer[website]=h5sw.com&customer[business_type]=commercial&customer[terms_client]=Net 10&customer[status]=Active&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/customers.xml
  def create
    @customer = Customer.new(params[:customer])
    @customer.company_id = current_company.id
    @phone1 = params[:customer][:phone1]
    @phone2 = params[:customer][:phone2]
    @phone3 = params[:customer][:phone3]
    @phone4 = params[:customer][:phone4]
    if @customer.save
      response_message = {:message => "Customer was created successfully.", :customer => @customer }
    else
      response_message = {:message => "Customer creation failed.Please try again"}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end
  
  #curl -X PUT -d 'customer[types]=customer&customer[company_name]=airtel&customer[address1]=Jayanagar&customer[address2]=Bangalore&customer[city]=Bangalore&customer[state]=Karnataka&customer[zip]=560011&customer[contact_id]=23&customer[account]=54154&customer[phone]=999-885-8844&customer[website]=h5sw.com&customer[business_type]=commercial&customer[terms_client]=Net 10&customer[status]=Active&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/customers/96.json 
  #curl -X PUT -d 'customer[types]=customer&customer[company_name]=airtel&customer[address1]=Jayanagar&customer[address2]=Bangalore&customer[city]=Bangalore&customer[state]=Karnataka&customer[zip]=560011&customer[contact_id]=23&customer[account]=54154&customer[phone]=999-885-8844&customer[website]=h5sw.com&customer[business_type]=commercial&customer[terms_client]=Net 10&customer[status]=Active&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/customers/96.xml
  def update
    @customer = Customer.find(params[:id])
    @phone1 = params[:customer][:phone1]
    @phone2 = params[:customer][:phone2]
    @phone3 = params[:customer][:phone3]
    @phone4 = params[:customer][:phone4]
    if @customer.update_attributes(params[:customer])
      response_message = {:message => "Customer was updated successfully." }
    else
      response_message = {:message => "Customer updation failed. Please try again"}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end
  
  #curl -X DELETE -d 'api_key=ypVSipVXC2Yd377jz58A'  http://localhost:3000/api/customers/96.json
   #curl -X DELETE -d 'api_key=ypVSipVXC2Yd377jz58A'  http://localhost:3000/api/customers/96.xml
  def destroy
    @customer = Customer.find(params[:id])
    if @customer.destroy
      response_message = {:message => "Customer was deleted successfully." }
    else
      response_message = {:message => "Customer deletion failed. Please try again"}
    end
     respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
     end
    end
 end
