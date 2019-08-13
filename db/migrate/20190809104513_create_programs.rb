class CreatePrograms < ActiveRecord::Migration
    def change
      create_table :programs do |t|
        t.string :facility_code, null: false, :limit => 8
        t.string :institution_name, null: false, :limit => 80
        t.string :program_type, null: false
        t.string :description, :limit => 40
        t.string :full_time_undergraduate, :limit => 15
        t.string :graduate, :limit => 15
        t.string :full_time_modifier, :limit => 1
        t.string :length, :limit => 7
      end
    end
  end