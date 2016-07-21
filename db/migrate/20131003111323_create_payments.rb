class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :payment_type
      t.string :amount
      t.string :card_number
      t.date :expires
      t.string :data
      t.string :check_number
      t.string :po_number
      t.string :tax
      t.string :balance
      t.integer :job_id
      t.integer :company_id

      t.timestamps
    end
  end
end
