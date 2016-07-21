class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :roll
      t.boolean :module
      t.string :customer
      t.string :jobs
      t.string :contacts
      t.string :reports
      t.string :settings_admin
      t.integer :company_id

      t.timestamps
    end
  end
end
