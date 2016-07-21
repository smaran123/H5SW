class Business < ActiveRecord::Base
   attr_accessible :biz_type, :company_id
   belongs_to :company
end
