class Jobsite < ActiveRecord::Base
  attr_accessible :name, :city, :state, :zip, :customer_id
  acts_as_gmappable :check_process => false

  belongs_to :customer
  has_many :documents
  has_many :notes
  has_many :items
  has_many :jobtimes
  validates :name, :city, :state, :zip, :customer, :presence => true

  #validates :name, :uniqueness => true

  def self.search(search)
    if search
      where('name ILIKE?', "%#{search}%")
    else
      scoped
    end
  end


  def gmaps4rails_address
    "#{self.city}, #{self.state}, #{self.zip}"
  end

  def gmaps4rails_infowindow
    "Jobsite: <br/><b>Name:&nbsp;</b> #{self.name}<br /><b>City:&nbsp;</b>#{self.city}<br /><b>State:&nbsp;</b> #{self.state}<br /><b>Zip:&nbsp;</b> #{self.zip}<br />"
  end
end
