class AddColumnsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs ,:name, :string
    add_column :jobs, :signature, :text
  end
end
