class RemoveJobdateFromJobtimes < ActiveRecord::Migration
  def up
    remove_column :jobtimes, :jobdate
  end

  def down
    add_column :jobtimes, :jobdate, :datetime
  end
end
