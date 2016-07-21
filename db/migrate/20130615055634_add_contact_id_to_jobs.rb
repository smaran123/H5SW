class AddContactIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :contact_id, :integer
  end
end
