class CreateTabs < ActiveRecord::Migration
  def change
    create_table :tabs do |t|
      t.string  :name
      t.string  :tab_type
      t.integer :position

      t.timestamps
    end
  end
end
