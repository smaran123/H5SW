class AddColumnsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :plan, :string
    add_column :companies, :stripe_card_token, :string
    add_column :companies, :no_of_users, :string
  end
end
