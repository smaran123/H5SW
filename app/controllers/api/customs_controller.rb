class Api::CustomsController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token

  # list of custom fields
  # curl -X GET -d 'type=Customer/Job&tab=id&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs.json
  def index
    if params[:type].present? && params[:type] =="Job"
      @default_tab = (params[:tab] ? params[:tab] : current_company.tabs.find_by_tab_type("Job").id)
    else
      @default_tab = (params[:tab] ? params[:tab] : current_company.tabs.first.id)
    end

    @tabs = current_company.tabs.where("tab_type=?", params[:type])
    @customs = current_company.customs.where("tab_id=? AND status=?", @default_tab, true).order('position asc')

    respond_to do |format|
      format.xml {render :xml => [@tabs, @customs]}
      format.json{render :json => [@tabs, @customs]}
    end
  end

  # create custom field for current tab
  # curl -X POST -d 'custom[name]=XXX&custom[field]=XXX&tab_name=XXX&drop_down_value=XXXX,XXXX,XXXX&type=Customer/Job&tab=id&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs.json
  def create
    @tabs = current_company.tabs.order("created_at asc")
    @tab = current_company.tabs.find(params[:tab])

    @custom = current_company.customs.new(params[:custom])

    #all the custom fields matching the condition
    @customs = current_company.customs.where("tab_id=? AND status=?", params[:tab], true)

    #set the position of the custom element
    if !@customs.empty?
      @positions = @customs.map{|cus| cus.position}
      @custom.position = @positions.compact.sort.last+1
    else
      @custom.position = 1
    end

    #save the custom element
    @custom.tab_id = params[:tab]
    if @custom.save
      #update tab name
      @change_tab_name = current_login.tabs.find(params[:tab])
      @change_tab_name.update_attributes(:name => params[:tab_name])

      #save values for textbox, dropdown or calendar
      DropdownValue.create(:custom_id => @custom.id, :company_id => @custom.company_id, :drop_value => params[:drop_down_value])
      
      response_message = {:message => "All the tabs are loaded, custom fields matching search criteria are loaded, position for custom field set, Custom field created with it's value, Tab name updated.", :custom => @custom}
    else
      response_message = {:message => "Custom field creation failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # update your label i.e. custom[name] 
  # curl -X PUT -d 'custom[name]=XXXX&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs/id.json
  def update
    @custom = Custom.find(params[:id])

    if @custom.update_attributes(params[:custom])
      response_message = {:message => "Label for custom field updated successfully", :custom => @custom}
    else
      response_message = {:message => "Label updation failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # update Text Box OR Calendar Values
  # curl -X PUT -d 'dropdown_value[drop_value]=XXXX&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs/id/update_dropdown_values.json
  def update_dropdown_values
    @dropdown_value = current_login.dropdown_values.find(params[:id])
    if @dropdown_value.update_attributes(params[:dropdown_value])
      response_message = {:message => "Custom field value updated successfully", :dropdown_value => @dropdown_value}
    else
      response_message = {:message => "Custom field value updation failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # update the values of dropdown list
  # curl -X PUT -d 'dropdown_value=XXXX, XXXX, XXXX&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs/id/update_dropdown.json
  def update_dropdown
    @dropdown_value = current_company.dropdown_values.find(params[:id])

    if @dropdown_value.update_attribute(:drop_value, params[:dropdown_value])
      response_message = {:message => "Custom field Dropdown List values updated successfully.", :dropdown_values => @dropdown_value}
    else
      response_message = {:message => "Custom field Dropdown List values updation failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # hide custom field  i.e. make status=false of the custom fields
  # curl -X PUT -d 'api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs/:id/update_status.json
  def update_status
    @custom = Custom.find(params[:id])

    if @custom.update_attribute(:status, false)
      response_message = {:message => "Custom field is made hidden", :custom => @custom}
    else
      response_message = {:message => "Custom field hiding failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # delete custom field
  # curl -X DELETE -d 'api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs/:id.json
  def destroy
    @custom = Custom.find(params[:id])

    if @custom.destroy
      response_message = {:message => "Custom field deleted successfully.", :custom => @custom}
    else
      response_message = {:message => "Custom field deletion failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :xml => response_message }
    end
  end

  # create tabs for custom fields
  # curl -X POST -d 'tab[name]=XXXX&type=Customer/Job&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs/create_tab.json
  def create_tab
    @tabs = current_login.tabs.where("tab_type=?", params[:type])
    @tab = current_company.tabs.new(params[:tab])
    @tab.tab_type = params[:type]

    if @tabs && @tabs.count >= 2
      response_message = {:message => "sorry cannot create more tabs"}
    else
      if @tab.save
        response_message = {:message => "Custom Tab created successfully", :tab => @tab}
      else
        response_message = {:message => "Custom Tab creation failed. Please try again!"}
      end
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # update tabs name
  # curl -X PUT -d 'updated_name=XXXX&api_key=E7tDAFxoiqneXMuhfpaq' http://localhost:3000/api/customs/:id/update_tab.json
  def update_tab
    @tabs = current_login.tabs
    @tab = Tab.find(params[:id])

    if @tab.update_attribute(:name, params[:updated_name])
      response_message = {:message => "Custom tab name updated successfully.", :tab => @tab}
    else
      response_message = {:message => "Custom tab name updation failed. Please try again!"}
    end

    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end
end
