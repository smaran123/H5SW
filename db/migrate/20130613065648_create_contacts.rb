class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :business
      t.string :email
      t.string :mobile
      t.string :name
      t.string :role
      t.string :twitter

      t.integer :company_id

      t.timestamps
    end
  end
end
