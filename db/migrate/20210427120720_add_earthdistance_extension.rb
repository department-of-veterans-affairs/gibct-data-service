class AddEarthdistanceExtension < ActiveRecord::Migration[5.2]
    def up
      safety_assured do
        execute "CREATE EXTENSION IF NOT EXISTS earthdistance;"
      end
    end
  
    def down
      safety_assured do
        execute "DROP EXTENSION IF EXISTS eartdistance;"
      end
    end
  end