class RenameBlobOnUpload < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :uploads, :blob }
    add_column :uploads, :body, :text 
  end
end
