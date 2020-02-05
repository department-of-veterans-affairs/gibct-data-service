class AddPgTrgmExtension < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    end
  end

  def down
    safety_assured do
      execute "DROP EXTENSION IF EXISTS pg_trgm;"
    end
  end
end
