module InventoriesHelper
   def subtotal
      ActionController::Base.helpers.number_to_currency(self[:subtotal])
  end
end
