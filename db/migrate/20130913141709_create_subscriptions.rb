class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer   :company_id
      t.decimal   :plan
      t.string    :stripe_card_token
      
      t.timestamps
    end
  end
end
