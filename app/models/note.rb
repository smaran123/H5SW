class Note < ActiveRecord::Base
  attr_accessible :note_type, :description, :notable_type, :notable_id, :company_id, :jobsite_id
  belongs_to :customer,  :polymorphic => true
  belongs_to :job,  :polymorphic => true
  belongs_to :company


  attr_accessible :notable_id, :jobsite_id, :presence => true
  attr_accessible :description, :note_type, :presence => true

  validates :notable_id, :note_type, :presence => true
end
