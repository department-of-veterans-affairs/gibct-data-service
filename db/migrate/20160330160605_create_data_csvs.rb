class CreateDataCsvs < ActiveRecord::Migration
  def change
    create_table :data_csvs do |t|
      # weams
      t.string :facility_code, null: false
      t.string :institution, null: false
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :accredited
      t.integer :bah
      t.string :poe
      t.string :yr
      t.string :poo_status
      t.string :applicable_law_code
      t.string :institution_of_higher_learning_indicator
      t.string :ojt_indicator
      t.string :correspondence_indicator
      t.string :flight_indicator
      t.string :non_college_degree_indicator

      # va_crosswalks
      t.string :ope 
      t.string :cross 

      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
      t.index :ope 
      t.index :cross
    end
  end
end
