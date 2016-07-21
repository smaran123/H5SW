class Role < ActiveRecord::Base
  attr_accessible :roll, :module, :customer, :jobs, :contacts, :reports, :settings_admin, :company_id, :jobtimes
  belongs_to :company

  validates :roll, :presence => true, :uniqueness => {:scope => :company_id, :message => "A role with this name already exists."}
  has_many :users, :dependent => :destroy

end
