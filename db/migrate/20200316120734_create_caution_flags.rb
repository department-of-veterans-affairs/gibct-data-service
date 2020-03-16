class CreateCautionFlags < ActiveRecord::Migration[5.2]
  def up
    create_table :caution_flags do |t|
      t.integer :institution_id
      t.integer :version_id
      t.string :source
      t.string :reason
      t.timestamps null: false
    end

    add_foreign_key :caution_flags, :versions, validate: false
    add_foreign_key :caution_flags, :institutions, validate: false
  end

  def down
    drop_table :caution_flags

    remove_foreign_key :caution_flags, :versions
    remove_foreign_key :caution_flags, :institutions
  end
end
