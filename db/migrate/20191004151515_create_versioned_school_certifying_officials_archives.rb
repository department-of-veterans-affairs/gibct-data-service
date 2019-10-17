class CreateVersionedSchoolCertifyingOfficialsArchives < ActiveRecord::Migration[5.0]
    def up
      safety_assured do
        execute "create table versioned_school_certifying_officials_archives (like versioned_school_certifying_officials
          including defaults
          including constraints
          including indexes
      );"
      end
    end
  
     def down
      drop_table :versioned_school_certifying_officials_archives
    end
  end