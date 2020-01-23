class AddCompletionDateToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :completed_at, :datetime
  end
end
