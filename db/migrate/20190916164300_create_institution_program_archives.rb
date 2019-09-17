class CreateInstitutionProgramArchives < ActiveRecord::Migration
  def up
    safety_assured do
      execute "create table institution_program_archives (like institution_programs
        including defaults
        including constraints
        including indexes
    );"
    end
  end

   def down
    drop_table :institution_program_archives
  end
end
