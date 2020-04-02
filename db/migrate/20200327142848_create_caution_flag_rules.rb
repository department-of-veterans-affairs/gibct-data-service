class CreateCautionFlagRules < ActiveRecord::Migration[5.2]
  def up
    create_table :caution_flag_rules do |t|
      t.belongs_to :rule, foreign_key: true
      t.string :title
      t.string :description
      t.string :link_text
      t.string :link_url
      t.timestamps
    end
  end

  def down
    drop_table :caution_flag_rules
  end
end
