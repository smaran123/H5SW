class AddMissingFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users,:encrypted_password,:string, :null => false, :default => ""
    add_column :users,:reset_password_token,:string
    add_column :users,:reset_password_sent_at,:datetime
    add_column :users,:remember_created_at,:datetime
    add_column :users,:sign_in_count,:integer, :default => 0
    add_column :users,:current_sign_in_at,:datetime
    add_column :users,:last_sign_in_at,:datetime
    add_column :users,:current_sign_in_ip,:string
    add_column :users,:last_sign_in_ip,:string
    add_column :users,:confirmation_token,:string
    add_column :users,:confirmed_at,:datetime
    add_column :users,:confirmation_sent_at,:datetime
    add_column :users,:unconfirmed_email,:string
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
  end
end
