class CreateCustoms < ActiveRecord::Migration
  def change
    create_table  :customs do |t|
      t.string    :name
      t.string    :field
      t.integer   :company_id
      t.string    :type

      t.timestamps
    end
  end
end
