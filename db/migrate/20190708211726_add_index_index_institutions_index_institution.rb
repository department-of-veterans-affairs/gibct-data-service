class AddIndexIndexInstitutionsIndexInstitution < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    safety_assured do
      execute 'CREATE INDEX CONCURRENTLY version_institutions_lower_institutions_idx ON institutions("version", lower(institution));'
    end
  end

  def down
    safety_assured do
      execute 'DROP INDEX version_institutions_lower_institutions_idx'
    end
  end
end
