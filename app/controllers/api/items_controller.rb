class Api::ItemsController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token
  
  #curl -X GET -d 'name=item_smo1&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/items/autocomplete_items.json
  #curl -X GET -d 'name=item_smo1&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/items/autocomplete_items.xml
  def autocomplete_items
    @items = Item.where("name ILIKE '%#{params[:name].to_s.downcase}%'and name NOT IN ('#{@not_names}')" )
    respond_to do |format|
      format.xml{render :xml => @items}
      format.json{render :json => @items}
    end
  end
  
  #curl -X GET -d 'name=itemsmo5&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/items/create_inventory.json
  def create_inventory
    @items = Item.where("name='#{params[:name]}'")
    if @items
      for item in @items
        if Inventory.exists?(:name => item.name, :company_id => current_company.id, :customer_id => session[:customer_id], :job_id => session[:job_id], :jobsite_id => session[:jobsite_id])
          @inventories = current_company.inventories
        else
          Inventory.create(:itemtype => item.itemtype,:qty => item.qty,:name => item.name, :number => item.number, :description => item.description, :unit_price => item.unit_price, :unit_cost => item.unit_cost, :company_id => current_company.id, :job_id => session[:job_id], :jobsite_id => session[:jobsite_id], :customer_id => session[:customer_id], :subtotal => (item.qty.nil? || item.unit_price.nil?) ? " " : (item.qty.to_f*item.unit_price.to_f) )
          @inventories = current_company.inventories
        end
      end
      @inventory = current_company.inventories.last
    response_message = { :message => "Inventory was created successfully.", :inventory=> @inventory}
    else
      response_message = { :message => "Please try again."}
    end
    respond_to do |format|
     format.xml{ render :xml => response_message }
     format.json{ render :json => response_message}
    end
  end
end
