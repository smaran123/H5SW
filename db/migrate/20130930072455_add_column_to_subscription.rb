class AddColumnToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :amount ,:string
  end
end
