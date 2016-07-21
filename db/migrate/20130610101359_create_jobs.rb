class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :reference_no,   :null => false, :default => ""
      t.datetime :due_date
      t.string :class_type,     :null => false, :default => ""
      t.string :assigned_to,    :null => false, :default => ""
      t.string :status,         :null => false, :default => ""
      #t.string :job_contact,    :null => false, :default => ""
      t.string :sales_person,   :null => false, :default => ""
      t.string :summary
      t.decimal :sub_total,     :precision => 8, :scale => 2, :null => false, :default => 0.00
      t.string :add_items
      #t.text :notes

      #new fields
      t.integer :job_number
      t.integer :customer_id
      t.integer :company_id

      t.timestamps
    end

    # create unique indexes
    add_index :jobs, :reference_no,     :unique => true
  end
end
