class AddVersionIdColumnToInstitutionsArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions_archives, :version_id, :bigint
  end
end
