class CreateCautionFlags < ActiveRecord::Migration[5.2]
  def up
    create_table :caution_flags do |t|
      t.string :facility_code
      t.integer :version_id
      t.string :type
      t.string :reason
      t.timestamps null: false
    end

    add_foreign_key :caution_flags, :versions, validate: false
  end

  def down
    drop_table :caution_flags

    remove_foreign_key :caution_flags, :versions
  end
end
