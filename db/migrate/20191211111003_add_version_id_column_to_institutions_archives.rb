class AddVersionIdColumnToInstitutionsArchives < ActiveRecord::Migration[5.1]
  def change
    add_column :institutions_archives, :version_id, :integer
  end
end
