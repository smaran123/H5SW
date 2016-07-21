class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :type
      t.string :qty
      t.string :number
      t.string :name
      t.text :description
      t.decimal :unit_cost
      t.decimal :unit_price
      t.string :job_item
      t.integer :company_id
      t.integer :customer_id
      t.integer :jobsite_id
      t.integer :job_id

      t.timestamps
    end
  end
end
