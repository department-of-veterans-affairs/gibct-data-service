class UpdateInstitutionProgramsIndex < ActiveRecord::Migration
  disable_ddl_transaction!
  
  def change
    remove_index :institution_programs, name: "index_institution_programs_on_facility_code_and_description"
    add_index :institution_programs,
              [:facility_code, :description, :version], 
              unique: true, 
              algorithm: :concurrently, 
              name: 'index_institution_programs'
  end
end
