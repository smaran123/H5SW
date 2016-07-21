class Api::InventoriesController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token
  
  #curl -X GET -d 'api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/inventories.json
  #curl -X GET -d 'api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/inventories.xml
  def index
    @inventories = current_company.inventories.find_all_by_job_id(params[:job_id])
    respond_to do |format|
      format.xml{ render :xml => @inventories }
      format.json{ render :json => @inventories }
    end
  end
  
  
  #curl -X POST -d 'inventory[itemtype]=SMO_item11&inventory[qty]=1&inventory[number]=SMOITEM21&inventory[name]=itemsmo11&inventory[description]=security keypad&inventory[unit_price]=55.33&inventory[unit_cost]=52.33&inventory[subtotal]=qty.to_f*unit_price&inventory[job_id]=241&inventory[customer_id]=64&inventory[jobsite_id]=39&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/inventories.json
  #curl -X POST -d 'inventory[itemtype]=SMO_item11&inventory[qty]=1&inventory[number]=SMOITEM21&inventory[name]=itemsmo11&inventory[description]=security keypad&inventory[unit_price]=55.33&inventory[unit_cost]=52.33&inventory[subtotal]=qty.to_f*unit_price&inventory[job_id]=241&inventory[customer_id]=64&inventory[jobsite_id]=39&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/inventories.xml
  def create
    @inventory = Inventory.new(params[:inventory])
    @inventory.company_id = current_company.id
     @inventory.subtotal = (params[:inventory][:qty].to_f*@inventory.unit_price) if params[:inventory][:qty].present?
    if @inventory.save
      response_message = { :message => "Item was created successfully." ,:inventory => @inventory}
    else
      response_message = { :message => "Please try again."}
    end
    respond_to do |format|
      format.xml{render :xml => response_message}
      format.json{ render :json => response_message }
    end
  end
  
  #curl -X PUT -d 'inventory[qty]=7&inventory[description]=security keypad&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/inventories/244.json
  def update
    @inventory = Inventory.find(params[:id])
    @inventory.subtotal = (params[:inventory][:qty].to_f*@inventory.unit_price) if params[:inventory][:qty].present?
    if @inventory.update_attributes(params[:inventory])
      @inventories = current_company.inventories
      response_message = {:message => "Item was updated successfully.", :inventory => @inventory}
    else
      response_message = {:message => "Please try again"}
    end
    respond_to do |format|
      format.xml{render :xml => response_message }
      format.json{ render :json => response_message }
    end
  end
  
  #curl -X DELETE -d 'api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/inventories/244.json
  def destroy
    @inventory = Inventory.find(params[:id])
    if @inventory.destroy
      response_message = {:message => "Item was deleted successfully."}
    else
      response_message = {:message => "Item deletion failed. Please try again."}
    end
    respond_to do |format|
      format.xml{render :xml => response_message }
      format.json{ render :json => response_message }
    end
  end
 end
