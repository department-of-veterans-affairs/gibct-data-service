class AddInstitutionColumnsToInstitutionPrograms < ActiveRecord::Migration
  def change
    add_column :institution_programs, :institution_name, :string
    add_column :institution_programs, :institution_city, :string
    add_column :institution_programs, :institution_state, :string
    add_column :institution_programs, :preferred_provider, :string
    add_column :institution_programs, :dod_bah, :int

    add_index :institution_programs, [:institition_name, :version], using: :btree
    add_index :institution_programs, [:institition_city, :version], using: :btree
    add_index :institution_programs, [:institution_name, :version], using: :btree
  
  end
end
