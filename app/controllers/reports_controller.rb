class ReportsController < ApplicationController
  before_filter :is_login?
  #before_filter :trial_period_expired?
  
  def index
    @jobs = current_login.jobs.paginate(:per_page => 10, :page => params[:page]).order('created_at desc')
  end
  
  def show
    @job = Job.find(params[:id])
      @total = 0
      if current_login.inventories.exists?(:job_id => @job.id) || current_login.jobtimes.exists?(:job_id => @job.id)
          @inventory = current_login.inventories.find_all_by_job_id(params[:id])
          @inventory.each do |inventory|
          @total = @total + (inventory.qty.to_f * inventory.unit_price.to_i)
          end
          @jobtime = current_login.jobtimes.find_all_by_job_id(params[:id])
          @jobtime.each do |jobtime|
          @total = @total + (jobtime.price.to_f)
          end
          @job.total = @total
          @job.update_attributes(:total => @job.total)
    end
  end

  def push_report_to_quickbook
    push_invoice_to_quickbook
     #@job.update_attributes(:status => 'invoiced')
  end
  
	 def send_mail
		@job = Job.find(params[:id])
		@company = Company.find(current_login.id)
    if @job.contact_id.present?
		CompanyMailer.send_job_report(@company,@job).deliver
    flash[:notice] = t('reports.send_mail.notice')
    else
      flash[:notice] = t('reports.send_mail.notice1')
    end
		respond_to do |format|
		  format.js
		end
	 end
	  
	  def job_report
		 @job = Job.find(params[:id])
		 render :pdf => "reports/job_report.html.erb"
  end
end
