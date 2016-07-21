class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :role_id
      t.string :name
      t.string :accounting_type
      t.string :accounting_name
      t.string :email
      t.boolean :smo_user, :default => true
      t.string :language
      t.string :time_zone
      t.integer :company_id
      t.timestamps
    end
  end
end
