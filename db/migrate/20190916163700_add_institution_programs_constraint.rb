class AddInstitutionProgramsConstraint < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    safety_assured {
      execute <<-SQL
        ALTER TABLE institution_programs ADD CONSTRAINT u_constraint UNIQUE (facility_code, description);
      SQL
    }
  end

  def down
    safety_assured {
      execute <<-SQL
        ALTER TABLE institution_programs DROP CONSTRAINT u_constraint;
      SQL
    }
  end
end
