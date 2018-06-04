class CreateYellowRibbonPrograms < ActiveRecord::Migration
  def change
    create_table :yellow_ribbon_programs do |t|
      t.integer :version, null: false, index: true
      t.integer :institution_id, null: false, index: true
      t.string :degree_level
      t.string :division_professional_school
      t.integer :number_of_students
      t.decimal :contribution_amount, precision: 12, scale: 2

      t.timestamps null: false
    end
  end
end
