class AddBlobFileToUploads < ActiveRecord::Migration[7.1]
  def change
    add_column :uploads, :blob_file, :binary
  end
end
