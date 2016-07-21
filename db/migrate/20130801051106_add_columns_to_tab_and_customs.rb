class AddColumnsToTabAndCustoms < ActiveRecord::Migration
  def up
    add_column    :dropdown_values, :company_id, :integer
    add_column    :tabs, :company_id, :integer
    remove_column :tabs, :position
  end
  def down
    remove_column :dropdown_values, :company_id
    remove_column :tabs, :company_id
    add_column :tabs, :position, :integer
  end
end
