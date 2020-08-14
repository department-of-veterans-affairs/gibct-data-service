class DropRule < ActiveRecord::Migration[5.2]
  def change
    if !table_exists?("caution_flag_rules") && table_exists?("rules")
      drop_table :rules
    end
  end
end
