class AddJobtimesToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :jobtimes, :string
  end
end
