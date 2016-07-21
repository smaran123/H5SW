class ChangeZipColumInCustomers < ActiveRecord::Migration
 def change
    change_column :customers, :zip, :string
  end
end
