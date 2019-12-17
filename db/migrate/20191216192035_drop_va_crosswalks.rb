class DropVaCrosswalks < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("va_crosswalks")
      drop_table :va_crosswalks
    end
  end
end
