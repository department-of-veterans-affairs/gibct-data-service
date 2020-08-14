class DropSec702School < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("sec702_schools")
      drop_table :sec702_schools
    end
  end
end
