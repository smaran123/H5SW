class Contact < ActiveRecord::Base
  attr_accessible :business, :email, :mobile, :name, :role, :twitter, :company_id, :jobsite_id, :customer_id, :mobile1, :mobile2, :mobile3, :mobile4, :business1, :business2, :business3, :business4
  attr_accessor :mobile1, :mobile2, :mobile3, :mobile4, :business1, :business2, :business3, :business4
  before_save :make_mobile
  before_save :make_business
  belongs_to :company

  validates :name,  :presence => true
  #validates :email, :uniqueness => true
  validates :customer_id, :presence => true

  def self.search(search)
    if search
      where('name ILIKE? OR role ILIKE? OR business LIKE? OR email ILIKE? OR twitter ILIKE? OR mobile LIKE?', "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
    else
      scoped
    end
  end

  def make_mobile
    if (@mobile1.present? and @mobile2.present? and @mobile3.present?) and !@mobile4.present?
      self.mobile = @mobile1.to_s+"-"+@mobile2.to_s+"-"+@mobile3.to_s
    elsif (@mobile1.present? and @mobile2.present? and @mobile3.present?) and @mobile4.present?
      self.mobile = @mobile1.to_s+"-"+@mobile2.to_s+"-"+@mobile3.to_s+"/"+@mobile4.to_s
    end
  end

  def mobile1
    self.mobile.to_s.split('-')[0] if self.mobile.present?
  end

  def mobile2
    self.mobile.to_s.split('-')[1]  if self.mobile.present?
  end

  def mobile3
    self.mobile.to_s.split('-')[2].split('/')[0]  if self.mobile.present? and !self.mobile.to_s.split('-')[2].nil?
  end

  def mobile4
    self.mobile.to_s.split('-')[2].split('/')[1]  if self.mobile.present? and !self.mobile.to_s.split('-')[2].nil?
  end


  def make_business
    if (@business1.present? and @business2.present? and @business3.present?) and !@business4.present?
      self.business = @business1.to_s+"-"+@business2.to_s+"-"+@business3.to_s
    elsif (@business1.present? and @business2.present? and @business3.present?) and @business4.present?
      self.business = @business1.to_s+"-"+@business2.to_s+"-"+@business3.to_s+"/"+@business4.to_s
    end
  end


  def business1
    self.business.to_s.split('-')[0] if self.business.present?
  end

  def business2
    self.business.to_s.split('-')[1]  if self.business.present?
  end

  def business3
    self.business.to_s.split('-')[2].split('/')[0]  if self.business.present? and !self.business.to_s.split('-')[2].nil?
  end

  def business4
    self.business.to_s.split('-')[2].split('/')[1]  if self.business.present? and !self.business.to_s.split('-')[2].nil?
  end

end
