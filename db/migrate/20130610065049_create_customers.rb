class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :types
      t.string :company_name
      t.integer :company_id
      t.string :parent_billing
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.integer :zip
      t.text :contact
      t.string :website
      t.string :business_type
      t.string :terms_client
      t.string :status
      t.string :account
      t.integer :phone
      t.string :action

      t.timestamps
    end
  end
end
