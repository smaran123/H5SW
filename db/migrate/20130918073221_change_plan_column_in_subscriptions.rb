class ChangePlanColumnInSubscriptions < ActiveRecord::Migration
 def change
    change_column :subscriptions, :plan, :float
  end
end
