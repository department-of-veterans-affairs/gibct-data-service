class AddInstitutionProgramsConstraint < ActiveRecord::Migration
  disable_ddl_transaction!
  safety_assured {
    def up
        execute <<-SQL
          ALTER TABLE institution_programs ADD CONSTRAINT u_constraint UNIQUE (facility_code, description);
        SQL
    end

    def down
        execute <<-SQL
          ALTER TABLE institution_programs DROP CONSTRAINT u_constraint;
        SQL
    end
  }
end
