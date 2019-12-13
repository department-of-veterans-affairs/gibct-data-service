class AddArfGiBills < ActiveRecord::Migration[5.2]
  def change
    unless table_exists?("arf_gibills")
      create_table "arf_gibills", id: :serial do |t|
        t.string "facility_code", null: false
        t.string "institution"
        t.integer "gibill", null: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index ["facility_code"], name: "index_arf_gibills_on_facility_code", unique: true
        t.index ["institution"], name: "index_arf_gibills_on_institution"
      end
    end
  end
end
