class AddBlobToUploads < ActiveRecord::Migration[7.1]
  def change
    add_column :uploads, :blob, :binary
  end
end
