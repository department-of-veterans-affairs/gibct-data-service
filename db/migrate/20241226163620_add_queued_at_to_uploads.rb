class AddQueuedAtToUploads < ActiveRecord::Migration[7.1]
  def change
    add_column :uploads, :queued_at, :datetime, precision: nil
  end
end
