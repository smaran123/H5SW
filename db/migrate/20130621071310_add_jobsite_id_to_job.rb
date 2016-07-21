class AddJobsiteIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :jobsite_id, :integer
  end
end
