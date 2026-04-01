class DropIndexesFromArchiveTables < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    remove_index :institution_programs_archives, [:description, :version]
    remove_index :institution_programs_archives, :institution_id
    remove_index :zipcode_rates_archives, [:version, :zip_code]
    remove_index :calculator_constant_versions_archives, :version_id
  end

  def down
    add_index :institution_programs_archives, [:description, :version], algorithm: :concurrently
    add_index :institution_programs_archives, :institution_id, algorithm: :concurrently
    add_index :zipcode_rates_archives, [:version, :zip_code], algorithm: :concurrently
    add_index :calculator_constant_versions_archives, :version_id, algorithm: :concurrently
  end
end
