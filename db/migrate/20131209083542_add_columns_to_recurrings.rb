class AddColumnsToRecurrings < ActiveRecord::Migration
  def change
    add_column :recurrings, :every, :string
    add_column :recurrings, :on, :string
  end
end
