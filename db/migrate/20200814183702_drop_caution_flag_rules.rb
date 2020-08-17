class DropCautionFlagRules < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("caution_flag_rules")
      drop_table :caution_flag_rules
    end
  end
end
