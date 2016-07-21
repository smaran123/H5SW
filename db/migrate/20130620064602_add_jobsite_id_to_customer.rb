class AddJobsiteIdToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :jobsite_id, :integer
  end
end
