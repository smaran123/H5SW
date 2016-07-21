class AddJobsiteIdToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :jobsite_id, :integer
  end
end
