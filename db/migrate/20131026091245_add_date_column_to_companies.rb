class AddDateColumnToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :subscription_date, :datetime
  end
end
