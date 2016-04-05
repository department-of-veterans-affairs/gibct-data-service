class CreateDataCsvs < ActiveRecord::Migration
  def change
    create_table :data_csvs do |t|
      t.string :facility_code, null: false
      t.string :institution, null: false
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :va_highest_degree_offered
      t.string :type # BEWARE!!!!
      t.integer :bah
      t.boolean :poe
      t.boolean :yr
      t.boolean :flight
      t.boolean :correspondence
      t.boolean :accredited

      # va_crosswalks
      t.string :ope, default: nil
      t.string :ope6, default: nil
      t.string :cross, default: nil

      # svas
      t.boolean :student_veteran, default: false
      t.string :student_veteran_link, default: nil
      
      # vsocs
      t.string :vetsuccess_name, default: nil
      t.string :vetsuccess_email, default: nil

      # Eight Keys
      t.string :eight_keys, default: nil
      
      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
      t.index :ope 
      t.index :cross
    end
  end
end
