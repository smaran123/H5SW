class AddJobsiteIdToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :jobsite_id, :integer
  end
end
