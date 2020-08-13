class DropP911Yrs < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("p911_yrs")
      drop_table :p911_yrs
    end
  end
end