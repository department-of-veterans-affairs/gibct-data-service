class CreateInstitutionsArchive < ActiveRecord::Migration
  def up
    execute "CREATE TABLE institutions_archives AS TABLE institutions WITH NO DATA;"
  end

  def down
    execute "DROP TABLE institutions_archives;"
  end
end
