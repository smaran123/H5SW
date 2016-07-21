class CreateDropdownValues < ActiveRecord::Migration
  def change
    create_table :dropdown_values do |t|
      t.string :drop_value
      t.integer :custom_id

      t.timestamps
    end
  end
end
