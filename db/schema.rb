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

ActiveRecord::Schema.define(version: 20170107202319) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crosswalks", force: :cascade do |t|
    t.string   "facility_code", null: false
    t.string   "institution"
    t.string   "cross"
    t.string   "city"
    t.string   "state"
    t.string   "ope"
    t.string   "notes"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "crosswalks", ["cross"], name: "index_crosswalks_on_cross", using: :btree
  add_index "crosswalks", ["facility_code"], name: "index_crosswalks_on_facility_code", unique: true, using: :btree
  add_index "crosswalks", ["institution"], name: "index_crosswalks_on_institution", using: :btree
  add_index "crosswalks", ["ope"], name: "index_crosswalks_on_ope", using: :btree

  create_table "eight_keys", force: :cascade do |t|
    t.string   "institution", null: false
    t.string   "city"
    t.string   "state"
    t.string   "cross"
    t.string   "ope"
    t.string   "notes"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "eight_keys", ["cross"], name: "index_eight_keys_on_cross", using: :btree
  add_index "eight_keys", ["institution"], name: "index_eight_keys_on_institution", using: :btree
  add_index "eight_keys", ["ope"], name: "index_eight_keys_on_ope", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

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

  create_table "versions", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.integer  "version",                    null: false
    t.boolean  "production", default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "versions", ["user_id"], name: "index_versions_on_user_id", unique: true, using: :btree
  add_index "versions", ["version"], name: "index_versions_on_version", using: :btree

  create_table "weams", force: :cascade do |t|
    t.string   "facility_code",                            null: false
    t.string   "institution",                              null: false
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.integer  "bah"
    t.boolean  "poe"
    t.boolean  "yr"
    t.string   "va_highest_degree_offered"
    t.string   "institution_type"
    t.boolean  "flight"
    t.boolean  "correspondence"
    t.boolean  "accredited"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "address_3"
    t.string   "poo_status"
    t.string   "applicable_law_code"
    t.boolean  "institution_of_higher_learning_indicator"
    t.boolean  "ojt_indicator"
    t.boolean  "correspondence_indicator"
    t.boolean  "flight_indicator"
    t.boolean  "non_college_degree_indicator"
    t.boolean  "approved"
    t.string   "cross"
    t.string   "ope"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "weams", ["facility_code"], name: "index_weams_on_facility_code", unique: true, using: :btree
  add_index "weams", ["institution"], name: "index_weams_on_institution", using: :btree
  add_index "weams", ["state"], name: "index_weams_on_state", using: :btree

end
