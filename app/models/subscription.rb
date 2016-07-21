class Subscription < ActiveRecord::Base
  #  attr_accessible :df

  # make a virtual attribute of stripe_card_token
  attr_accessible :plan, :company_id, :stripe_card_token
  
  validates :plan, :presence => true
  
end
