class AddColumnsCustomerIdColumnToRecurrings < ActiveRecord::Migration
  def change
    add_column :recurrings, :customer_id, :integer
    add_column :recurrings, :jobsite_id, :integer
  end
end
