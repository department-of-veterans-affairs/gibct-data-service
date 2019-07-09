class AddIndexIndexInstitutionsIndexInstitution < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    safety_assured do
      # This index will not be properly represented in schema.rb but it will be present on db's that run this migration.
      execute 'CREATE INDEX CONCURRENTLY version_institutions_lower_institutions_idx ON institutions("version", lower(institution));'
    end
  end

  def down
    safety_assured do
      execute 'DROP INDEX version_institutions_lower_institutions_idx'
    end
  end
end
