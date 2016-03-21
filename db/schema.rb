# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160316164659) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "csv_files", force: :cascade do |t|
    t.string   "name",                      null: false
    t.datetime "upload_date",               null: false
    t.string   "delimiter",   default: ",", null: false
    t.string   "type",                      null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "csv_files", ["name"], name: "index_csv_files_on_name", using: :btree
  add_index "csv_files", ["upload_date"], name: "index_csv_files_on_upload_date", using: :btree

  create_table "csv_storages", force: :cascade do |t|
    t.binary   "data_store"
    t.string   "csv_file_type", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "csv_storages", ["csv_file_type"], name: "index_csv_storages_on_csv_file_type", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "va_crosswalks", force: :cascade do |t|
    t.string   "facility_code", null: false
    t.string   "institution",   null: false
    t.string   "city"
    t.string   "state"
    t.string   "cross"
    t.string   "ope"
    t.string   "notes"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "va_crosswalks", ["city"], name: "index_va_crosswalks_on_city", using: :btree
  add_index "va_crosswalks", ["cross"], name: "index_va_crosswalks_on_cross", using: :btree
  add_index "va_crosswalks", ["facility_code"], name: "index_va_crosswalks_on_facility_code", unique: true, using: :btree
  add_index "va_crosswalks", ["institution"], name: "index_va_crosswalks_on_institution", using: :btree
  add_index "va_crosswalks", ["ope"], name: "index_va_crosswalks_on_ope", using: :btree
  add_index "va_crosswalks", ["state"], name: "index_va_crosswalks_on_state", using: :btree

  create_table "weams", force: :cascade do |t|
    t.string   "facility_code",            null: false
    t.string   "institution",              null: false
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "accredited"
    t.string   "bah"
    t.string   "poe"
    t.string   "yr"
    t.string   "ojt_indicator"
    t.string   "correspondence_indicator"
    t.string   "flight_indicator"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "weams", ["city"], name: "index_weams_on_city", using: :btree
  add_index "weams", ["country"], name: "index_weams_on_country", using: :btree
  add_index "weams", ["facility_code"], name: "index_weams_on_facility_code", unique: true, using: :btree
  add_index "weams", ["institution"], name: "index_weams_on_institution", using: :btree
  add_index "weams", ["state"], name: "index_weams_on_state", using: :btree

end
