class CreateInstitutionsArchive < ActiveRecord::Migration[4.2]
  def up
    safety_assured do
      execute "create table institutions_archives (like institutions
        including defaults
        including constraints
        including indexes
    );"
    end
  end

   def down
    drop_table :institutions_archives
  end
end
