class CreateInstitutionsArchive < ActiveRecord::Migration
  def up
    execute "CREATE TABLE institutions_archive AS TABLE institutions WITH NO DATA;"
  end

  def down
    execute "DROP TABLE institutions_archive;"
  end
end
