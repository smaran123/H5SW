class Payment < ActiveRecord::Base
   attr_accessible :payment_type, :amount, :card_number, :expires, :data, :check_number, :po_number, :tax, :balance, :job_id, :company_id
   belongs_to :job
   belongs_to :company
   
  def amount
    "%.2f" % self[:amount]
  end
end
