class RemoveAsyncColumnsFromUpload < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :uploads, :status_message }
    safety_assured { remove_column :uploads, :body }
    safety_assured { remove_column :uploads, :queued_at }
    safety_assured { remove_column :uploads, :canceled_at }
  end
end
