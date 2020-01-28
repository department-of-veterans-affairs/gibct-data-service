class AddCompletionDateToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :completed_at, :datetime
    reversible do |dir|
      dir.up { Upload.where(ok: true).update_all('completed_at = updated_at') }
    end
  end
end
