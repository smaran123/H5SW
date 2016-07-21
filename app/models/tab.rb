class Tab < ActiveRecord::Base
  attr_accessible :name, :tab_type, :company_id

  has_many :customs
  belongs_to :company

  validates :name, :presence => true
  validates :name, :uniqueness => {:scope => [:company_id, :tab_type], :message => "Tab with this name is already created"}
end