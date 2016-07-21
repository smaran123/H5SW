class ChangeDropValueToDropdownValues < ActiveRecord::Migration
  def up
    change_column :dropdown_values, :drop_value, :text
  end

  def down
    change_column :dropdown_values, :drop_value, :string
  end
end
