class UpdateInstitutionProgramsArchivesIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :institution_programs_archives, name: "index_institution_programs_archives"

    add_index :institution_programs_archives,
              [:institution_id],
              using: :btree,
              algorithm: :concurrently

    add_index :institution_programs_archives,
              [:description, :version],
              unique: true,
              algorithm: :concurrently,
              name: 'index_institution_programs_archives'
  end
end
