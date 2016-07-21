class AddAuthenticationTokenToCompanies < ActiveRecord::Migration
  def change
    ## Token authenticatable
      add_column :companies, :authentication_token, :string
  end
end
