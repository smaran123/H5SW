class AddImageColumnsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :image_file_name, :string
    add_column :jobs, :image_file_size, :integer
    add_column :jobs, :image_content_type, :string
    add_column :jobs, :image_updated_at, :datetime
  end
end
