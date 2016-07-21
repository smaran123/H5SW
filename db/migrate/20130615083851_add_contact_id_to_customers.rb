class AddContactIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :contact_id, :integer
  end
end
