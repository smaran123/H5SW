class AddColumnToCompanies < ActiveRecord::Migration
  def change
     add_column :companies, :status, :string, :default => "trial"
  end
end
