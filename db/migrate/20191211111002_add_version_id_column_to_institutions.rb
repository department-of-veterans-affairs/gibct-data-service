class AddVersionIdColumnToInstitutions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :institutions, :version, foreign_key: true, index: false
    add_index :institutions, :version_id, algorithm: :concurrently
  end
end
