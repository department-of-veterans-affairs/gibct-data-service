class DropAccreditationsTable < ActiveRecord::Migration
  def change
    drop_table :accreditations do |t|
      t.string   "cross"
      t.string   "accreditation_status"
      t.string   "csv_accreditation_type"
      t.string   "accreditation_type"
      t.string   "periods"
      t.string   "institution_ipeds_unitid"
      t.string   "campus_ipeds_unitid"
      t.string   "agency_name"
      t.string   "ope6"
      t.string   "ope"
      t.string   "institution"
      t.integer  "institution_id"
      t.string   "institution_name"
      t.string   "institution_address"
      t.string   "institution_city"
      t.string   "institution_state"
      t.string   "institution_zip"
      t.string   "institution_phone"
      t.string   "institution_web_address"
      t.integer  "campus_id"
      t.string   "campus_name"
      t.string   "campus_address"
      t.string   "campus_city"
      t.string   "campus_state"
      t.string   "campus_zip"
      t.string   "agency_status"
      t.string   "program_name"
      t.string   "accreditation_csv_status"
      t.string   "accreditation_date_type"
      t.timestamps null: false

      t.index :cross
      t.index :institution
      t.index :ope
      t.index :ope6
    end
  end
end
