class CreateJobsites < ActiveRecord::Migration
  def change
    create_table :jobsites do |t|
      t.string :name
      t.string :city
      t.string :state
      t.string :zip
      t.integer :customer_id

      t.timestamps
    end
  end
end
