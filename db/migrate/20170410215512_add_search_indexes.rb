class AddSearchIndexes < ActiveRecord::Migration[4.2]
  def up
    execute "CREATE INDEX index_institutions_institution_lprefix 
             ON institutions (lower(institution) text_pattern_ops);"
  end

  def down
    execute "DROP INDEX index_institutions_institution_lprefix;"
  end
end
