class AddColumnsToJobtimes < ActiveRecord::Migration
  def change
    add_column :jobtimes ,:start_time,:datetime
    add_column :jobtimes, :end_time, :datetime
  end
end
