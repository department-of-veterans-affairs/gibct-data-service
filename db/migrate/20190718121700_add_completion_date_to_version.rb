class AddCompletionDateToVersion < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :completed_at, :datetime
  end
end
