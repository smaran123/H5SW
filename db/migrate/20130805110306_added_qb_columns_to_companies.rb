class AddedQbColumnsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :access_token, :string
    add_column :companies, :access_secret, :string
    add_column :companies, :realm_id, :string
  end
end
