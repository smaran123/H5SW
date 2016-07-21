class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.string :type
      t.string :qty
      t.string :number
      t.string :name
      t.text :description
      t.decimal :unit_cost
      t.decimal :unit_price
      t.decimal :subtotal
      t.string :job_item
      t.integer :company_id
      t.integer :customer_id
      t.integer :jobsite_id
      t.integer :job_id
      t.integer :item_id

      t.timestamps
    end
  end
end
