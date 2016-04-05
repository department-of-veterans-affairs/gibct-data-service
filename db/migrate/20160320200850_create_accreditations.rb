class CreateAccreditations < ActiveRecord::Migration
  def change
    create_table :accreditations do |t|

      t.string :institution_name
      t.string :campus_name
      t.string :institution       
      t.string :ope
      t.string :ope6
      t.string :institution_ipeds_unitid
      t.string :campus_ipeds_unitid
      t.string :cross
      t.string :csv_accreditation_type
      t.string :accreditation_type
      t.string :agency_name, null: false
      t.string :accreditation_status
      t.string :periods

      t.timestamps null: false

      t.index :institution
      t.index :cross
      t.index :ope 
      t.index :ope6
    end
  end
end
