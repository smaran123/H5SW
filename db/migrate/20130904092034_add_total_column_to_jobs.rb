class AddTotalColumnToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :total,:decimal
  end
end
