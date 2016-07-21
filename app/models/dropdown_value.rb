class DropdownValue < ActiveRecord::Base
  attr_accessible :custom_id, :drop_value, :company_id, :customer_id, :jobsite_id, :job_id

  belongs_to :custom
  belongs_to :company
end
