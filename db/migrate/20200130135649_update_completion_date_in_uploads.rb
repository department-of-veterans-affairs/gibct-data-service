class UpdateCompletionDateInUploads < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up { Upload.update_all('completed_at = updated_at') }
    end
  end
end
