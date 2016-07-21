class AddStatusFieldToCustoms < ActiveRecord::Migration
  def change
    add_column :customs, :status, :boolean, :default => true
  end
end
