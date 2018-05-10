class CreateSchoolClosures < ActiveRecord::Migration
  def change
    create_table :school_closures do |t|
      t.string :facility_code, null: false
      t.string :institution_name
      t.boolean :school_closing
      t.string :school_closing_date
      t.text :school_closing_message
      t.text :notes

      t.timestamps null: false
      t.index :facility_code, unique: true
    end
  end
end
