class AddTrigramIndexesToInstitutions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_institution ON institutions USING gin(institution gin_trgm_ops);"
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_city ON institutions USING gin(city gin_trgm_ops);"
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_address_1 ON institutions USING gin(LOWER(address_1) gin_trgm_ops);"
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_address_2 ON institutions USING gin(LOWER(address_2) gin_trgm_ops);"
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_address_3 ON institutions USING gin(LOWER(address_3) gin_trgm_ops);"
    end
  end

  def down
    safety_assured do
      execute "DROP INDEX index_institutions_on_institution;"
      execute "DROP INDEX index_institutions_on_city;"
      execute "DROP INDEX index_institutions_on_address_1;"
      execute "DROP INDEX index_institutions_on_address_2;"
      execute "DROP INDEX index_institutions_on_address_3;"
    end
  end
end
