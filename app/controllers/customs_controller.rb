class CustomsController < ApplicationController
  before_filter :is_login?
  before_filter :access_role?
  before_filter :display_custom, :only => ["new", "create"]
  #before_filter :trial_period_expired?

  before_filter :find_customer_information

  def index
    if params[:type].present? && params[:type] =="Job"
      @default_tab = (params[:tab] ? params[:tab] : current_login.tabs.find_by_tab_type("Job").id)
    else
      @default_tab = (params[:tab] ? params[:tab] : current_login.tabs.first.id)
    end

    @tabs = current_login.tabs.where("tab_type=?", params[:type]).order("created_at asc")
    @customs = current_login.customs.where("tab_id=? AND status=?", @default_tab.to_i, true).order('position asc')
    #    if params[:type]=="Job"
    #      @customs = search_by_session(current_login.customs).where("tab_id=? and job_id =? and status=?", @default_tab.to_i, session[:job_id], true).order('position asc')
    #    else
    #      @customs = search_by_session(current_login.customs).where("tab_id=? and status=?", @default_tab.to_i, true).order('position asc')
    #    end
  end

  def display_this_in_new_and_create
    @tabs = current_login.tabs.where("tab_type=? OR tab_type=?", "Customer", "Job").order("created_at asc")
    @tab = current_login.tabs.find_by_id(params[:tab])
  end

  def new
    display_this_in_new_and_create
    @custom = current_login.customs.new
  end


  def create
    display_this_in_new_and_create
    #all the parameters from new form
    @custom = current_login.customs.new(params[:custom])

    #all the custom fields matching this condition
    @customs = current_login.customs.where("tab_id=? AND status=?", params[:tab], true).order('position asc')

    #set the position of the custom element
    if !@customs.empty?
      @positions = @customs.map{|cus| cus.position}
      @custom.position = @positions.compact.sort.last+1
    else
      @custom.position = 1
    end

    if params[:custom][:field] == "Legend"
      dropdown_value = params[:drop_down_value1]
    elsif params[:custom][:field] == "Table"
      check_for_empty_params
      @custom.drop_value = [params[:field_1], params[:field_2], params[:field_3],params[:field_4], params[:field_5], params[:field_6],params[:field_7], params[:field_8], params[:field_9],params[:field_10], params[:field_11]].join(", ")
    else
      @custom.drop_value = params[:drop_down_value]
    end

    #save the custom element
    if @custom.save

      #update tab name
      @change_tab_name = current_login.tabs.find(params[:tab])
      @change_tab_name.update_attributes(:name => params[:tab_name])

      #save values for textbox, dropdown or calendar
      unless params[:custom][:field] == "Table"
        DropdownValue.create(:custom_id => @custom.id, :company_id => @custom.company_id, :drop_value => dropdown_value)
      end

      flash[:notice] = t('customs.create.notice')
      redirect_to new_custom_path(:tab => @tab.id, :type => @tab.tab_type)
    else
      render 'new'
    end
  end

  def check_for_empty_params
    params[:field_1] = params[:field_1]=="" ? "-" : params[:field_1]
    params[:field_2] = params[:field_2]=="" ? "-" : params[:field_2]
    params[:field_3] = params[:field_3]=="" ? "-" : params[:field_3]
    params[:field_4] = params[:field_4]=="" ? "-" : params[:field_4]
    params[:field_5] = params[:field_5]=="" ? "-" : params[:field_5]
    params[:field_6] = params[:field_6]=="" ? "-" : params[:field_6]
    params[:field_7] = params[:field_7]=="" ? "-" : params[:field_7]
    params[:field_8] = params[:field_8]=="" ? "-" : params[:field_8]
    params[:field_9] = params[:field_9]=="" ? "-" : params[:field_9]
    params[:field_10] = params[:field_10]=="" ? "-" : params[:field_10]
    params[:field_11] = params[:field_11]=="" ? "-" : params[:field_11]
  end


  # edit your label
  def edit
    @custom = Custom.find(params[:id])
    @dropdown_values = DropdownValue.find_by_custom_id_and_company_id(params[:id], current_login.id)
  end

  # update your label
  def update
    @custom = Custom.find(params[:id])
    if @custom.update_attributes(params[:custom])
      render
    else
      render :action => "edit"
    end
  end

  def get_dropdown_values
    @custom = Custom.find(params[:custom_id])
    @drop_downvalue = current_login.dropdown_values.find(params[:dropdown_id])   
    render
  end

  # update textfield, or calendar values
  
  def update_dropdown_values
    @custom = Custom.find(params[:dropdown_value][:custom_id])
    
    if params[:type] == "Job"
      if DropdownValue.exists?(:custom_id => params[:custom_id], :job_id => session[:job_id], :company_id => current_login.id)
        # update value for this job
        @drop_downvalue = current_login.dropdown_values.find_by_custom_id_and_job_id(params[:custom_id], session[:job_id])
        @drop_downvalue.update_attributes(params[:dropdown_value])
      else
        # create new value for this job
        @drop_downvalue = current_login.dropdown_values.new(params[:dropdown_value])
        @drop_downvalue.save
      end
    else
      if session[:jobsite_id].present? && session[:jobsite_id] != "All" && session[:jobsite_id] != "None"

        # update jobsite and customer both
        if DropdownValue.exists?(:custom_id => params[:custom_id], :customer_id => session[:customer_id], :company_id => current_login.id, :jobsite_id => session[:jobsite_id])
          # update value for this customer and jobsite
          @drop_downvalue = current_login.dropdown_values.find_by_custom_id_and_customer_id_and_jobsite_id(params[:custom_id], session[:customer_id], session[:jobsite_id])
          @drop_downvalue.update_attributes(params[:dropdown_value])
        else
          # create value for this customer and jobsite
          @drop_downvalue = current_login.dropdown_values.new(params[:dropdown_value])
          @drop_downvalue.save
        end
      else
        # update customer only
        if DropdownValue.exists?(:custom_id => params[:custom_id], :customer_id => session[:customer_id], :company_id => current_login.id)
          # update value for this customer and jobsite
          @drop_downvalue = current_login.dropdown_values.find_by_custom_id_and_customer_id_and_jobsite_id(params[:custom_id], session[:customer_id], 0)
          @drop_downvalue.update_attributes(params[:dropdown_value])
        else
          # create value for this customer and jobsite
          @drop_downvalue = current_login.dropdown_values.new(params[:dropdown_value])
          @drop_downvalue.save
        end
      end
    end

    render
  end


  #delete and hide records
  def destroy
    @custom = Custom.find(params[:id])
    @custom.destroy
  end

  def update_status
    @custom = Custom.find(params[:id])
    @custom.update_attributes(:status => false)
  end
  #end

  #update all the values of dropdown list
  def edit_dropdown
    @custom_id = params[:cus_id]
    @custom = Custom.find(params[:cus_id])
    @dropdown_values =  current_login.customs.find(params[:cus_id]).drop_value
  end

  def update_dropdown
    @custom = Custom.find(params[:id])
    @dropdown_value = current_login.customs.find(params[:id])
    @dropdown_value.update_attribute(:drop_value, params[:dropdown_value])
  end



  def update_customer_selection
    @custom = current_login.customs.find(params[:id])
    
    if params[:type] == "Job"
      if DropdownValue.exists?(:custom_id => params[:id], :job_id => session[:job_id], :company_id => current_login.id)
        # update value for this job
        @drop_downvalue = current_login.dropdown_values.find_by_custom_id_and_job_id(params[:id], session[:job_id])
        @drop_downvalue.update_attributes(params[:dropdown_value])
      else
        # create new value for this job
        @drop_downvalue = current_login.dropdown_values.new(params[:dropdown_value])
        @drop_downvalue.custom_id = params[:id]
        @drop_downvalue.job_id = session[:job_id]
        @drop_downvalue.customer_id = session[:customer_id]
        @drop_downvalue.jobsite_id = session[:jobsite_id]
        @drop_downvalue.save
      end
    else
      if session[:jobsite_id].present? && session[:jobsite_id] != 0 && session[:jobsite_id] != "All" && session[:jobsite_id] != "None"
        # update jobsite and customer both
        if DropdownValue.exists?(:custom_id => params[:id], :customer_id => session[:customer_id], :company_id => current_login.id, :jobsite_id => session[:jobsite_id])
          # update value for this customer and jobsite
          @drop_downvalue = current_login.dropdown_values.find_by_custom_id_and_customer_id_and_jobsite_id(params[:id], session[:customer_id], session[:jobsite_id])
          @drop_downvalue.update_attributes(params[:dropdown_value])
        else
          # create value for this customer and jobsite
          @drop_downvalue = current_login.dropdown_values.new(params[:dropdown_value])
          @drop_downvalue.custom_id = params[:id]
          @drop_downvalue.customer_id = session[:customer_id]
          @drop_downvalue.jobsite_id = session[:jobsite_id]
          @drop_downvalue.save
        end
      else
        # update customer only
        if DropdownValue.exists?(:custom_id => params[:id], :customer_id => session[:customer_id], :company_id => current_login.id)
          # update value for this customer and jobsite
          #@drop_downvalue = current_login.dropdown_values.find_by_custom_id_and_customer_id_and_jobsite_id(params[:id], session[:customer_id], 0)
          @drop_downvalue = current_login.dropdown_values.where("custom_id=? and customer_id=? and (jobsite_id IS NULL OR jobsite_id=0)", params[:id],  session[:customer_id])
          @drop_downvalue = @drop_downvalue.first if @drop_downvalue.present?
          @drop_downvalue.update_attributes(params[:dropdown_value])
        else
          # create value for this customer and jobsite
          @drop_downvalue = current_login.dropdown_values.new(params[:dropdown_value])
          @drop_downvalue.custom_id = params[:id]
          @drop_downvalue.customer_id = session[:customer_id]
          @drop_downvalue.jobsite_id = session[:jobsite_id]
          @drop_downvalue.save
        end
      end
    end
  end
  #end of updation of update dropdown values


  
  def display_custom
    @customs = current_login.customs.where("tab_id=? AND status=?", params[:tab].to_i, true).order('position asc')
  end

  # update the position of the custom fields
  def update_position
    @custom = Custom.find(params[:id])
    if params[:pos_1] != params[:pos_2]
      if params[:pos_1] > params[:pos_2]
        @find_customs = current_login.customs.where("tab_id=? and position BETWEEN ? and ? and position != ? AND status=?", params[:tab].to_i, params[:pos_2],params[:pos_1],params[:pos_1], true)
        @find_customs.each do |cus|
          cus.update_attribute(:position,cus.position+1)
        end
      elsif params[:pos_1] < params[:pos_2]
        @find_customs = current_login.customs.where("tab_id=? and position BETWEEN ? and ? and position != ? AND status=?", params[:tab].to_i, params[:pos_1],params[:pos_2],params[:pos_1], true)
        @find_customs.each do |cus|
          cus.update_attribute(:position,cus.position-1)
        end
      end
      @custom.update_attribute(:position,params[:pos_2])
    end
    respond_to do |format|
      format.js
    end
  end

  # actions for creating tabs
  def new_tab
    @tabs = current_login.tabs.where("tab_type=?", params[:type]).order("created_at asc")
    @tab = Tab.new
  end

  def create_tab
    @tabs = current_login.tabs.where("tab_type=?", params[:type]).order("created_at asc")
    @tab = Tab.new(params[:tab])

    if @tabs.present? && @tabs.count >= 2
      flash[:error] = t('customs.create_tab.error')
      render 'new_tab'
    else
      if @tab.save
        flash[:notice] = "Custom Tab for #{params[:type]} created successfully"
        redirect_to new_tab_customs_path(:type=> params[:type])
      else
        render 'new_tab'
      end
    end
  end

  def update_tab
    @tabs = current_login.tabs.order("created_at asc")
    @tab = Tab.find(params[:id])
    @tab.update_attribute(:name, params[:updated_name])
  end
  # end of the action for creating tabs



  # CRUD table field
  def create_table_fields
    if params[:type] == "Job"
      DropdownValue.create(:custom_id => params[:custom_id], :company_id => current_login.id, :drop_value => params[:drop_value], :customer_id => session[:customer_id], :jobsite_id => session[:jobsite_id], :job_id => session[:job_id])
    else
      if session[:jobsite_id].present? && session[:jobsite_id] != nil && session[:jobsite_id] != "All" && session[:jobsite_id] != "None"
        DropdownValue.create(:custom_id => params[:custom_id], :company_id => current_login.id, :drop_value => params[:drop_value], :customer_id => session[:customer_id], :jobsite_id => session[:jobsite_id])
      else
        DropdownValue.create(:custom_id => params[:custom_id], :company_id => current_login.id, :drop_value => params[:drop_value], :customer_id => session[:customer_id])
      end
    end
    
    @custom = Custom.find(params[:custom_id])
  end

  def edit_table
    @dropdown_value = current_login.dropdown_values.find(params[:id])
    @values = @dropdown_value.drop_value.split(",")
    render
  end

  def edit_table_heading
    @dropdown_value = current_login.customs.find(params[:id])
    @values = @dropdown_value.drop_value.split(",")
    render
  end

  def update_table
    @dropdown_value = current_login.dropdown_values.find(params[:id])
    @dropdown_value.update_attribute(:drop_value, params[:drop_value])
    @custom = Custom.find(@dropdown_value.custom_id)
    render
  end

  def update_heading
    @dropdown_value = current_login.customs.find(params[:id])
    @dropdown_value.update_attribute(:drop_value, params[:drop_value])
    @custom = Custom.find(@dropdown_value.id)
    render
  end

  def delete_table
    @dropdown_value = current_login.dropdown_values.find(params[:id])
    @dropdown_value.destroy
    respond_to do |format|
      format.js
    end
  end


  # edit and update legend field
  def edit_legend_field
    @custom = current_login.customs.find(params[:id])
    @dropdown_value = current_login.dropdown_values.find_by_custom_id(@custom.id)
  end

  def update_legend_field
    @custom = current_login.customs.find(params[:dropdown_value][:custom_id])
    @dropdown_value = current_login.dropdown_values.find_by_custom_id(@custom.id)
    @dropdown_value.update_attributes(:drop_value => params[:dropdown_value][:drop_value])
  end
  # end updating legend field

  def find_customer_information
    if session[:customer_id].present? && session[:customer_id] != "All" && session[:customer_id] != "None"
      @customer = current_login.customers.find(session[:customer_id])
    end
  end
  
  def print_custominfo
    if current_login.tabs.exists? (params[:tab])
      @tab = current_login.tabs.find(params[:tab])
    end
    render :pdf => "customs/print_custominfo.html.erb"
  end
  
  def email_custominfo
    if current_login.customers.exists? (session[:customer_id])
    @customer = current_login.customers.find(session[:customer_id])
    end
    @job = current_login.jobs.find(session[:job_id])
    @tab = current_login.tabs.find(params[:tab])
    if @job.contact_id.present?
    CompanyMailer.send_custominfo(current_login, @customer, @job, @tab).deliver
    flash[:notice] = t('customs.email_custominfo.notice')
    else
      flash[:alert] = t('customs.email_custominfo.alert')
    end
    respond_to do |format|
      format.js
    end
  end
  
  def email_customer
    if params[:email].present? && params[:subject].present? && params[:body].present?
    @email = params[:email]
    @subject = params[:subject]
    @body = params[:body]
    CompanyMailer.email_custom(current_login, @email, @subject, @body).deliver
    flash[:notice] = t('customs.email_customer.notice')
    end
  end
end