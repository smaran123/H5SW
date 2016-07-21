class AddJobsremainingColumsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :new_company_period, :datetime
    add_column :companies, :jobs_remaining, :string
    add_column :companies, :user_firstname, :string
    add_column :companies, :user_lastname, :string
  end
end
