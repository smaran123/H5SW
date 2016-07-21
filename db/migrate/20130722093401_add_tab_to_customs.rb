class AddTabToCustoms < ActiveRecord::Migration
  def change
    add_column :customs, :tab, :string
  end
end
