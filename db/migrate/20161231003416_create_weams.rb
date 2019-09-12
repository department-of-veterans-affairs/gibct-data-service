class CreateWeams < ActiveRecord::Migration[4.2]
  def change
    create_table :weams do |t|
      # Used in the building of DataCsv
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
      t.string :institution_type_name, null: false
      t.boolean :flight
      t.boolean :correspondence
      t.boolean :accredited
      t.boolean :ojt_indicator
      t.boolean :correspondence_indicator
      t.boolean :flight_indicator
      t.boolean :non_college_degree_indicator
      t.boolean :institution_of_higher_learning_indicator
      t.string :poo_status
      t.string :applicable_law_code
      t.boolean :approved

      # Not used in building DataCsv, but used in exporting source csv
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :cross
      t.string :ope
      t.string :ope6

      t.timestamps null: false
      t.index :facility_code, unique: true
      t.index :institution
      t.index :state
    end
  end
end
