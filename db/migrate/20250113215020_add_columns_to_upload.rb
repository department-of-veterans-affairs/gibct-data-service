class AddColumnsToUpload < ActiveRecord::Migration[7.1]
  def change
    add_column :uploads, :blob, :string
    add_column :uploads, :status_message, :string
    add_column :uploads, :queued_at, :datetime, precision: nil
    add_column :uploads, :canceled_at, :datetime, precision: nil
  end
end
