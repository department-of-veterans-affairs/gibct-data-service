class CreateCautionFlagRules < ActiveRecord::Migration[5.2]
  def up
    create_table :caution_flag_rules do |t|
      t.integer :rule_id
      t.string :title
      t.string :description
      t.string :link_text
      t.string :link_url
      t.timestamps
    end

    add_foreign_key :caution_flag_rules, :rules, validate: false
  end

  def down
    drop_table :caution_flag_rules
  end
end
