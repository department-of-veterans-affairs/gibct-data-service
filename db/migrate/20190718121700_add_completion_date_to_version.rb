class AddCompletionDateToVersion < ActiveRecord::Migration
  def change
    add_column :versions, :completed_at, :datetime
  end
end
