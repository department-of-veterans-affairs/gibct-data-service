class AddMultipleFilesToUploads < ActiveRecord::Migration[6.1]
  def change
    add_column :uploads, :multiple_files, :boolean, default: false
  end
end
