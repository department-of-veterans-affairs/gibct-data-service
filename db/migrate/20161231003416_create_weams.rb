class CreateWeams < ActiveRecord::Migration
  def change
    create_table :weams do |t|
      t.string :facility_code, null: false
    	t.string :institution, null: false
    	t.string :city
    	t.string :state
    	t.string :zip
      t.string :country
      t.integer :bah
			t.boolean :poe
			t.boolean :yr
      t.string :va_highest_degree_offered
      t.string :institution_type
      t.boolean :flight
      t.boolean :correspondence
      t.boolean :accredited

      # Not in data.csv
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :poo_status
      t.string :applicable_law_code
      t.boolean :institution_of_higher_learning_indicator
      t.boolean :ojt_indicator
      t.boolean :correspondence_indicator
      t.boolean :flight_indicator
      t.boolean :non_college_degree_indicator
      t.boolean :approved
      t.string :cross
      t.string :ope

      t.timestamps null: false
      t.index :facility_code, unique: true
      t.index :institution
      t.index :state
    end
  end
end
