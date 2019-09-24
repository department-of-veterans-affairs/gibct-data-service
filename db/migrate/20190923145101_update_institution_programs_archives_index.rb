class UpdateInstitutionProgramsArchivesIndex < ActiveRecord::Migration
  disable_ddl_transaction!
  
  def change
    remove_index :institution_programs_archives, name: "institution_programs_archives_facility_code_description_idx"
    add_index :institution_programs_archives,
              [:facility_code, :description, :version], 
              unique: true, 
              algorithm: :concurrently, 
              name: 'index_institution_programs_archives'
  end
end
