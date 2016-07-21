class Api::JobtimesController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token
  
  #curl -X GET -d 'job_id=248&api_key=XYBxz9Fyxx5pWwQsoE1a' http://localhost:3000/api/jobtimes.xml
  def index
    @jobtimes = current_company.jobtimes.find_all_by_job_id(params[:job_id])
    respond_to do |format|
      format.xml {render :xml => @jobtimes }
      format.json { render :json => @jobtimes }
    end
  end
 
#curl -X POST -d 'jobtime[timetype]=Scheduled Time&jobtime[qty]=2&jobtime[user]=Amrutha&jobtime[service]=11&jobtime[job_id]=103&jobtime[customer_id]=37&jobtime[start_time]=2013-08-10 09:07:00&jobtime[end_time]=2013-08-10 11:07:00&jobtime[billable]=true&api_key=HKp1jVJ2Ypsj3tnyy6oA' http://localhost:3000/api/jobtimes/jobtime_shedule.json
  def jobtime_shedule
    @jobtime = Jobtime.new(params[:jobtime])

    @qty = @jobtime.qty.to_i.hours
    @item = Item.find(@jobtime.service)

    #calculate end_time
    @jobtime.end_time = @jobtime.start_time+@qty

    #calculate cost
    @jobtime.cost = @item.unit_cost * @qty

    #calculate price
    if(@jobtime.billable.present?)
      @jobtime.price = @item.unit_price * @qty
    else
      @jobtime.price = 0
    end
    puts @jobtime.errors.inspect
    if @jobtime.save
      response_message = {:message => "Time was scheduled successfully.",:jobtime => @jobtime }
    else
      response_message = {:message => "Please try again."}
    end
    respond_to do |format|
      format.xml{render :xml => response_message }
      format.json{render :json => response_message }
    end
  end
   
  # curl -X POST -d 'start_time=XXXX&end_time=XXXX&service_item_id=XXXX&hours=XX&minutes=XX&seconds=XX&customer_id=XXXX&job_id=XXXX&jobsite_id=XXXX&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobtimes.json
  # curl -X POST -d 'start_time=2013-08-06 17:54:21&end_time=2013-08-06 18:30:25&service_item_id=93&hours=02&minutes=25&seconds=60&customer_id=64&job_id=241&jobsite_id=39&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/jobtimes.json
  def create
    @start_time = params[:start_time].to_datetime.strftime("%Y-%m-%d %H:%M:%S")
    @end_time = params[:end_time].to_datetime.strftime("%Y-%m-%d %H:%M:%S")
    @service = params[:service_item_id]

    @hours = params[:hours]
    @minutes = params[:minutes]
    @seconds = params[:seconds]

    @quantity = @hours.to_s+':'+@minutes.to_s+':'+@seconds.to_s
    
    @jobtime = Jobtime.new(:start_time => @start_time, :end_time => @end_time,:qty => @quantity,:company_id => current_login.id,:job_id => params[:job_id],:jobsite_id => params[:jobsite_id],:customer_id => params[:customer_id],:user => current_login.name, :timetype => "Actual Time", :service => @service)
    
    if @jobtime.save(:validate => false)
      response_message = {:message => "Jobtime successfully created.", :jobtime => @jobtime}
    else
      response_message = {:message => "Jobtime creation failed. Please try again."}      
    end
    
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end
end
