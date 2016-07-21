class AddColumnsToJobsites < ActiveRecord::Migration
  def change
    add_column :jobsites, :latitude,  :float
    add_column :jobsites, :longitude, :float
    add_column :jobsites, :gmaps, :boolean, :default => false
  end
end
