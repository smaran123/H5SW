class AddCustomerJobsiteAndJobIdToDropdownValues < ActiveRecord::Migration
  def change
    # add customer_id, jobsite_id and job_id in dropdown_values and remove from custom fields
    add_column :dropdown_values, :customer_id, :integer
    add_column :dropdown_values, :jobsite_id, :integer
    add_column :dropdown_values, :job_id, :integer

    remove_column :customs, :customer_id
    remove_column :customs, :jobsite_id
    remove_column :customs, :job_id
  end
end
