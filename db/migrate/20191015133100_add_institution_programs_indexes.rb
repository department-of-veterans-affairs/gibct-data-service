class AddInstitutionProgramsIndexes < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :institution_programs,
              [:version, :description],
              using: :btree,
              algorithm: :concurrently
    add_index :institution_programs,
              [:version, :institution_name],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ip_version_institution_name
    add_index :institution_programs,
              [:version, :city],
              using: :btree,
              algorithm: :concurrently
    add_index :institution_programs,
              [:version, :state],
              using: :btree,
              algorithm: :concurrently
    add_index :institution_programs,
              [:version, :country],
              using: :btree,
              algorithm: :concurrently
    add_index :institution_programs,
              [:version, :preferred_provider],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ip_version_institution_programs
  end
end
