class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :biz_type
      t.integer :company_id
      t.timestamps
    end
  end
end
