class DropRule < ActiveRecord::Migration[5.2]
  def change
    drop_table :rules, if_exists: true
  end
end
