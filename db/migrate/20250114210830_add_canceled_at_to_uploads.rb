class AddCanceledAtToUploads < ActiveRecord::Migration[7.1]
  def change
    add_column :uploads, :canceled_at, :datetime, precision: nil
  end
end
