class AddQuickbookCustomerIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :quickbook_customer_id, :integer
  end
end
