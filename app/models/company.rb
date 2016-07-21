class Company < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable,:omniauthable, :omniauth_providers => [:intuit]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :created_at, :email, :password, :password_confirmation, :remember_me, :name, :phone_number, :access_token, :access_secret, :realm_id, :status, :plan, :stripe_card_token, :no_of_users, :approved, :subscription_date, :new_company_period,:jobs_remaining, :user_firstname, :user_lastname
  validates :name, :presence => true, :uniqueness => true
  #validates :user_firstname,:user_lastname, :presence => true
  #validates :phone_number, :presence =>true, :numericality => {:only_integer => true, :message => "Please Enter Valid Phone Number" }
  validates :phone_number, format: { with: /\d{3}-\d{3}-\d{4}/, :message => "Please Enter Valid Phone Number" }
  has_many :customers
  has_many :jobs
  has_many :contacts
  has_many :notes
  has_many :documents
  has_many :users, :dependent => :destroy
  has_many :roles, :dependent => :destroy
  has_many :items
  has_many :customs
  has_many :inventories
  has_many :jobtimes
  has_many :tabs
  has_many :dropdown_values
  has_many :businesses
  has_many :jobstatuses
  has_many :payments
  has_many :recurrings

  before_save :ensure_authentication_token
  before_create :active_for_authentication? 
  after_create :create_item
  before_create :new_company
  after_update :update_new
  after_create :create_user
  after_update :update_status
  
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["name", "phone_number", "status", "email", "no_of_users"]
      all.each do |company|
        csv << company.attributes.values_at("name", "phone_number", "status", "email", "no_of_users")
      end
    end
  end
  
  def create_item
    Item.create(:itemtype => "Default", :qty => 1, :number => "1", :name => "Default item", :description => "default item", :unit_cost => 250, :unit_price => 200, :company_id => self.id)
  end
   
  def new_company
    self.new_company_period = Date.today.to_datetime + 30
    self.jobs_remaining = "30"
  end
   
   
  def create_user
    role = Role.create(:roll =>"Admin", :company_id => self.id, :jobtimes => "Read-Only", :customer => "All", :jobs => "All", :contacts => "All", :reports => "With-Pricing",:settings_admin => "All" )
    User.create(:name => self.user_firstname,:email => self.email, :accounting_name => self.user_lastname, :smo_user => true,:company_id => self.id, :language => "English",:role_id => role.id).save(:validate => false)
  end
   
   
  def update_new
    company = Company.find(self.id)
    if company.new_company_period == Date.today.to_datetime
      company.update_attributes(:new_company_period =>(Date.today.to_datetime + 30.days), :jobs_remaining => "30")
    end
  end
   
  def update_status
    company = Company.find(self.id)
    if company.status == "paid"
      if company.subscription_date == Date.today.to_datetime
        company.update_attributes(:status => "Free user") 
      end
    end
  end
   
  # openid for QuickBooks
  def self.find_for_open_id(access_token, signed_in_resource=nil)
    data = access_token.info
    if company = Company.where(:email => data["email"]).first
      company
    else
      company =Company.new(:email => data["email"], :password => Devise.friendly_token[0,20])
      company.save(:validate => false)
      company
    end
  end
  
end
