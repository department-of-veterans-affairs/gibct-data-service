class CreateWeams < ActiveRecord::Migration
  def change
    create_table :weams do |t|
      t.string :facility_code, index: true, unique: true, null: false
    	t.string :institution, index: true, null: false
    	t.string :city
    	t.string :state, index: true
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
      t.string :institution_of_higher_learning_indicator
      t.string :ojt_indicator
      t.string :correspondence_indicator
      t.string :flight_indicator
      t.string :non_college_degree_indicator
      t.boolean :approved, null: false
      t.string :ipeds
      t.string :ope

      t.timestamps null: false
    end
  end
end
