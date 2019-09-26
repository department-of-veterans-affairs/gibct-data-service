class AddInstitutionColumnsToInstitutionPrograms < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :institution_programs, :institution_name, :string
    add_column :institution_programs, :institution_city, :string
    add_column :institution_programs, :institution_state, :string
    add_column :institution_programs, :institution_country, :string
    add_column :institution_programs, :preferred_provider, :string
    add_column :institution_programs, :dod_bah, :int

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
              [:version, :institution_city],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ip_version_institution_city
    add_index :institution_programs,
              [:version, :institution_state],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ip_version_institution_state
    add_index :institution_programs,
              [:version, :institution_country],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ip_version_institution_country
    add_index :institution_programs,
              [:version, :preferred_provider],
              using: :btree,
              algorithm: :concurrently,
              name: :index_ip_version_institution_programs
  end
end
