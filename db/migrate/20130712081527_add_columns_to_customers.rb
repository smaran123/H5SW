class AddColumnsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :latitude,  :float
    add_column :customers, :longitude, :float
    add_column :customers, :gmaps, :boolean, :default => false
  end
end
