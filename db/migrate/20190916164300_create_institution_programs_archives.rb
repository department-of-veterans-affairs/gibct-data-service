class CreateInstitutionProgramsArchives < ActiveRecord::Migration
  def up
    safety_assured do
      execute "create table institution_programs_archives (like institution_programs
        including defaults
        including constraints
        including indexes
    );"
    end
  end

   def down
    drop_table :institution_programs_archives
  end
end
