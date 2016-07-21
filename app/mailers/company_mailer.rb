class CompanyMailer < ActionMailer::Base
  default :from => "h5sw.info@gmail.com"

  def send_job_details(company,job)
    @company = company
    @date_and_time = Time.now
    @job = job
    @contact = Contact.find(@job.contact_id)
    mail(:to => @contact.email, :subject => "Job details")
  end

  def user_link(user,company)
    @user = user
    @company = company
    mail(:to => @user.email, :subject => "Company #{@company.name} created you")
  end
  
  def send_job_report(company,job)
    @company = company
    @date_and_time = Time.now
    @job = job
    @contact = Contact.find(@job.contact_id)
    mail(:to => @contact.email, :subject => "Job Report")
  end
  
  def send_custominfo(company, customer, job, tab)
    @company = company
    @date_and_time = Time.now
    @customers = customer
    @job = job
    @tab = tab
    @contact = Contact.find(@job.contact_id)
    mail(:to =>@contact.email,:subject => "Custom Fields Information")
  end
  
  def email_custom(company, email, subject, body)
    @company = company
    @email = email
    @subject = subject
    @body = body
    mail(:from =>@company.email, :to => @email, :subject => @subject, :body => @body)
  end
  
  def email_invoice(company,job)
    @job = job
    @contact = Contact.find(@job.contact_id)
    mail(:to => @contact.email, :subject => "Job Invoice")
  end
  
  def send_invoice(company,job)
    @job = job
    @contact = Contact.find(@job.contact_id)
    mail(:to => @contact.email, :subject => "Job Invoice")
  end
  
end
