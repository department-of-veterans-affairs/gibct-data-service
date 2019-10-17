class AddInstitutionProgramsIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :institution_programs,
              [:institution_id],
              using: :btree,
              algorithm: :concurrently
  end
end
