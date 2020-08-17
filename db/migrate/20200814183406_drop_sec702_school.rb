class DropSec702School < ActiveRecord::Migration[5.2]
  def change
    drop_table :sec702_schools, if_exists: true
  end
end
