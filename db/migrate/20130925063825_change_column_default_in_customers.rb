class ChangeColumnDefaultInCustomers < ActiveRecord::Migration
  def change
    change_column_default :customers, :status, "Active"
  end
end
