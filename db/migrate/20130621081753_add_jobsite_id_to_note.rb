class AddJobsiteIdToNote < ActiveRecord::Migration
  def change
    add_column :notes, :jobsite_id, :integer
  end
end
