class CreateInstitutionPrograms < ActiveRecord::Migration
  def change
    create_table :institution_programs do |t|
      t.string :facility_code, null: false
      t.string :program_type
      t.string :description, null: false
      t.string :full_time_undergraduate
      t.string :graduate
      t.string :full_time_modifier
      t.string :length_in_hours
      t.integer :version

      t.index [:facility_code, :description], unique: true
    end
  end
end
