class AddBillableAndCostAndPriceToJobtimes < ActiveRecord::Migration
  def change
    add_column :jobtimes, :billable, :boolean, :default => true
    add_column :jobtimes, :cost, :decimal
    add_column :jobtimes, :price, :decimal
  end
end
