class AddPositionToCustoms < ActiveRecord::Migration
  def change
    add_column :customs,:position,:integer
  end
end
