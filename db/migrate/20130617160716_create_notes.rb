class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :note_type
      t.text :description
      t.references :notable, :polymorphic => true
      t.integer :company_id
      t.timestamps
    end
  end
end
