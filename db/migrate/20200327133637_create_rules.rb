class CreateRules < ActiveRecord::Migration[5.2]
  def up
    create_table :rules do |t|
      t.string :rule_table, null: false
      t.string :matcher, null: false
      t.string :action, null: false
      t.string :subject
      t.string :object
      t.string :predicate

      t.timestamps
    end
  end

  def down
    drop_table :rules
  end
end
