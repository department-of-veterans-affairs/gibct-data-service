class CreateSec109ClosedSchool < ActiveRecord::Migration[4.2]
    def change
      create_table :sec109_closed_schools do |t|
        t.string :facility_code
        t.string :school_name
        t.boolean :closure109
      end
    end
  end