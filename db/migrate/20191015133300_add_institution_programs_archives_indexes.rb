class AddInstitutionProgramsArchivesIndexes < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :institution_programs_archives,
              [:version, :description],
              using: :btree,
              algorithm: :concurrently
    add_index :institution_programs_archives,
              [:version, :institution_name],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ipa_version_institution_name
    add_index :institution_programs_archives,
              [:version, :city],
              using: :btree,
              algorithm: :concurrently
    add_index :institution_programs_archives,
              [:version, :state],
              using: :btree,
              algorithm: :concurrently
    add_index :institution_programs_archives,
              [:version, :country],
              using: :btree,
              algorithm: :concurrently
    add_index :institution_programs_archives,
              [:version, :preferred_provider],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ipa_version_institution_programs
  end
end
