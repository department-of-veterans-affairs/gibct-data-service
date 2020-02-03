class AddTrigramIndexesToInstitutions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_institution_trgm ON institutions USING gin(institution gin_trgm_ops);"
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_city_trgm ON institutions USING gin(city gin_trgm_ops);"
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_address_1_trgm ON institutions USING gin(LOWER(address_1) gin_trgm_ops);"
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_address_2_trgm ON institutions USING gin(LOWER(address_2) gin_trgm_ops);"
      execute "CREATE INDEX CONCURRENTLY index_institutions_on_address_3_trgm ON institutions USING gin(LOWER(address_3) gin_trgm_ops);"
    end
  end

  def down
    safety_assured do
      execute "DROP INDEX index_institutions_on_institution_trgm;"
      execute "DROP INDEX index_institutions_on_city_trgm;"
      execute "DROP INDEX index_institutions_on_address_1_trgm;"
      execute "DROP INDEX index_institutions_on_address_2_trgm;"
      execute "DROP INDEX index_institutions_on_address_3_trgm;"
    end
  end
end
