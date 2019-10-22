class UpdateInstitutionProgramsIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :institution_programs, name: "index_institution_programs"

    add_index :institution_programs,
              [:institution_id],
              using: :btree,
              algorithm: :concurrently

    add_index :institution_programs,
              [:description, :version],
              algorithm: :concurrently,
              name: 'index_institution_programs'
  end
end
