class Job < ActiveRecord::Base
   
  has_attached_file :image
  attr_accessible :total, :add_items, :assigned_to, :class_type, :due_date, :reference_no, :sales_person, :status, :sub_total, :summary, :job_number, :customer_id, :company_id, :contact_id, :jobsite_id, :name, :signature, :image, :quickbook_tax_amount, :quickbook_total_amount
  # Data validations
  validates :reference_no, :class_type, :status, :assigned_to, :due_date, :sub_total, :presence => true
  validates :reference_no, :uniqueness => true
  #validates_numericality_of :sub_total, :greater_than => 0, :message => "must be greater than 0"
  #validates :sub_total, :format => { :with => /^[0-9]{1,5}((\.[0-9]{1,5})?)$/, :message => "should be a valid price less than 6 digit number" }
  validates :customer_id, :presence => true

  belongs_to :customer
  belongs_to :company
  has_many :notes, :as => :notable
  has_many :documents, :as => :documentable
  has_many :items
  has_many :inventories
  has_many :jobtimes
  has_many :payments

 
  def self.search(search)
    if search
      where('reference_no ILIKE? OR status ILIKE? OR summary ILIKE?', "%#{search}%","%#{search}%","%#{search}%" )
    else
      scoped
    end
  end
  
  def self.total_on(date)
    where("status=? AND date(created_at) = ?",'open',date).count
  end

  def self.closed_jobs(date)
    where("status=? AND date(updated_at) = ?",'closed',date).count
  end

	def self.open_jobs(date)
    Date.today-date
  end
  
  
  def total
    "%.2f" % self[:total]
  end
  
  validate :jobs_valid, :on => :create
  
  def jobs_valid
    company = Company.find(company_id)
    unless company.status == "paid"
      if company.jobs_remaining == "0"
        errors.add(:base, "Your account is configured for one free user with 30 jobs per month. To add another user and get unlimited jobs please subscribe")
      end
    end
  end
end

