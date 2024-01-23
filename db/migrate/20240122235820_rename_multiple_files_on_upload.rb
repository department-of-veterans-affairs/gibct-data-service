class RenameMultipleFilesOnUpload < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :uploads, :multiple_files }
    add_column :uploads, :multiple_file_upload, :boolean, default: false
  end
end
