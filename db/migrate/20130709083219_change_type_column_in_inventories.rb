class ChangeTypeColumnInInventories < ActiveRecord::Migration
  def change
    rename_column :inventories, :type, :itemtype
  end
end
