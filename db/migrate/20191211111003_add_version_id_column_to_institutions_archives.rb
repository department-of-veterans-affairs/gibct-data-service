class AddVersionIdColumnToInstitutionsArchives < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :institutions_archives, :version, foreign_key: true, index: false
    add_index :institutions_archives, :version_id, algorithm: :concurrently
  end
end
