class CreateSchoolCertifyingOfficialsArchives < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute "create table school_certifying_officials_archives (like school_certifying_officials
        including defaults
        including constraints
      );"
    end
  end
  
  def down
    drop_table :school_certifying_officials_archives
  end
end
