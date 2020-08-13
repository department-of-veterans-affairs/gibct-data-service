class DropP911Tfs < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("p911_tfs")
      drop_table :p911_tfs
    end
  end
end