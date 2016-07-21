class AddDropValueToCustoms < ActiveRecord::Migration
  def change
    add_column :customs, :drop_value, :string
  end
end
