class Inventory < ActiveRecord::Base
  attr_accessible :itemtype, :qty, :number, :name, :description, :unit_cost, :unit_price, :job_item, :job_id, :company_id, :customer_id, :jobsite_id, :subtotal
   belongs_to :company
   belongs_to :customer
   belongs_to :job
   belongs_to :jobsite
   belongs_to :items

   def subtotal
    "$%.2f" % self[:subtotal]
   end
   
   def unit_price
    "%.2f" % self[:unit_price]
  end
   
end
