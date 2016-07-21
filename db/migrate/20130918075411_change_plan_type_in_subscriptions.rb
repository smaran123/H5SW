class ChangePlanTypeInSubscriptions < ActiveRecord::Migration
  def change
    change_column :subscriptions, :plan, :string
  end
end
