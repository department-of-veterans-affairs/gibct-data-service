class AddSearchIndexes < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_institutions_institution_lprefix 
             ON institutions (lower(institution) text_pattern_ops);"
  end

  def down
    execute "DROP INDEX index_institutions_institution_lprefix;"
  end
end
