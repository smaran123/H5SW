class AddQuickbookItemIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :quickbook_item_id, :integer
  end
end
