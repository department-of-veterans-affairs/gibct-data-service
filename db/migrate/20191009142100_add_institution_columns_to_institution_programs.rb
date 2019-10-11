class AddInstitutionColumnsToInstitutionPrograms < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :institution_programs, :institution_name, :string
    add_column :institution_programs, :city, :string
    add_column :institution_programs, :state, :string
    add_column :institution_programs, :country, :string
    add_column :institution_programs, :preferred_provider, :boolean
    add_column :institution_programs, :dod_bah, :int
    add_column :institution_programs, :va_bah, :float

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
