class AddCustomerJobsiteAndJobIdToCustoms < ActiveRecord::Migration
  def change
    add_column :customs, :customer_id, :integer
    add_column :customs, :jobsite_id, :integer
    add_column :customs, :job_id, :integer
  end
end
