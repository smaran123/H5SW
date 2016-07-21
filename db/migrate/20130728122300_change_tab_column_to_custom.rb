class ChangeTabColumnToCustom < ActiveRecord::Migration
  def change
    remove_column :customs, :tab
    add_column    :customs, :tab_id, :integer
  end
end
