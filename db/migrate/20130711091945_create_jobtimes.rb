class CreateJobtimes < ActiveRecord::Migration
  def change
    create_table :jobtimes do |t|
      t.string :timetype
      t.datetime :jobdate
      t.string :qty
      t.string :user
      t.string :service
      t.integer :job_id
      t.integer :jobsite_id
      t.integer :company_id
      t.integer :customer_id
      t.timestamps
    end
  end
end
