class RemoveTypeInCustoms < ActiveRecord::Migration
  def up
    remove_column :customs,:type
    add_column :customs,:cus_type,:string
  end

  def down
    add_column :customs,:type,:string
    remove_column :customs,:cus_type
  end
end
