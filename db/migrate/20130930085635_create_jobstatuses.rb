class CreateJobstatuses < ActiveRecord::Migration
  def change
    create_table :jobstatuses do |t|
      t.string :status
      t.integer :company_id
      t.timestamps
    end
  end
end
