class AddCompanyIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :company_id, :integer
  end
end
