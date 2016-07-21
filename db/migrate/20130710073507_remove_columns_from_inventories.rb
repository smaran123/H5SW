class RemoveColumnsFromInventories < ActiveRecord::Migration
  def up
     remove_column :inventories, :job_item
     remove_column :inventories, :item_id
  end

  def down
    add_column :inventories, :job_item, :string
    add_column :inventories, :item_id,  :integer
  end
end
