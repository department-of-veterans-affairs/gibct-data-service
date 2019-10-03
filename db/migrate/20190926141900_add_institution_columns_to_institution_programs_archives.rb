class AddInstitutionColumnsToInstitutionProgramsArchives < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_column :institution_programs_archives, :institution_name, :string
    add_column :institution_programs_archives, :institution_city, :string
    add_column :institution_programs_archives, :institution_state, :string
    add_column :institution_programs_archives, :institution_country, :string
    add_column :institution_programs_archives, :preferred_provider, :boolean
    add_column :institution_programs_archives, :dod_bah, :int
    add_column :institution_programs_archives, :va_bah, :float

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
              [:version, :institution_city],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ipa_version_institution_city
    add_index :institution_programs_archives,
              [:version, :institution_state],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ipa_version_institution_state
    add_index :institution_programs_archives,
              [:version, :institution_country],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ipa_version_institution_country
    add_index :institution_programs_archives,
              [:version, :preferred_provider],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ipa_version_institution_programs
  end
end
