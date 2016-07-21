class CreateRecurrings < ActiveRecord::Migration
  def change
    create_table :recurrings do |t|
      t.string :name
      t.string :template_type
      t.string :interval
      t.string :days_inadvance
      t.datetime :start_date
      t.datetime :end_date
      t.integer :job_id
      t.integer :company_id
      t.timestamps
    end
  end
end
