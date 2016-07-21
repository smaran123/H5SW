class ItemsController < ApplicationController
  before_filter :is_login?
  before_filter :session_types
  #before_filter :trial_period_expired?


    def index
      @items = current_login.items.paginate(:per_page =>10, :page => params[:page])
    end

  #  def new
  #    @item = Item.new
  #  end
  #
  #  def create
  #    @item = Item.new(params[:item])
  #    @item.company_id = current_login.id
  #
  #    if @item.save
  #      flash[:notice]= "Item was successfully created "
  #      redirect_to inventories_path
  #    else
  #      render :action => "new"
  #    end
  #  end

  def autocomplete_items
    @not_names = params[:not_list].split(',').join("','")
#    quickbook_items(@item)
    @items = current_login.items.where("name ILIKE '%#{params[:name].to_s.downcase}%' and name NOT IN ('#{@not_names}')" )
    respond_to do |format|
      format.js
    end
  end
  

  def create_inventory
    @items = Item.where("name='#{params[:name]}'")
    if @items
      for item in @items
        if Inventory.exists?(:name => item.name, :company_id => current_login.id, :customer_id => session[:customer_id], :job_id => session[:job_id], :jobsite_id => session[:jobsite_id])
          @inventories = current_login.inventories.find_all_by_job_id(session[:job_id])
        else
          Inventory.create(:itemtype => item.itemtype,:qty => item.qty,:name => item.name, :number => item.number, :description => item.description, :unit_price => item.unit_price, :unit_cost => item.unit_cost, :company_id => current_login.id, :job_id => session[:job_id], :jobsite_id => session[:jobsite_id], :customer_id => session[:customer_id], :subtotal => (item.qty.nil? || item.unit_price.nil?) ? " " : (item.qty.to_f*item.unit_price.to_f) )
          @inventories = current_login.inventories.find_all_by_job_id(session[:job_id])
        end
      end      
    end
    respond_to do |format|
      format.js
    end
  end
  
#  def quickbook_items(item)
#    #push data to QuickBooks
#    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, current_login.access_token, current_login.access_secret)
#
#    #creating items in QuickBooks
#    item_service = Quickeebooks::Online::Service::Item.new
#    item_service.access_token = oauth_client
#    item_service.realm_id = current_login.realm_id
#    item_service.list
#    @items = @items.entries
#  end
end