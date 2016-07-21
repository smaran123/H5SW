class AddQuickbookTaxAmountToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :quickbook_tax_amount, :decimal
    add_column :jobs, :quickbook_total_amount, :decimal 
  end
end
