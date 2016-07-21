class Jobstatus < ActiveRecord::Base
  attr_accessible :status, :company_id
   belongs_to :company
end
