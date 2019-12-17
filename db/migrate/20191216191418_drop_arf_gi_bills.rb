class DropArfGiBills < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("arf_gibills")
      drop_table :arf_gibills
    end
  end
end
