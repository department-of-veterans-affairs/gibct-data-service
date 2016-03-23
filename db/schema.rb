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

ActiveRecord::Schema.define(version: 20160323132547) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accreditations", force: :cascade do |t|
    t.string   "institution_name"
    t.string   "ope"
    t.string   "institution_ipeds_unitid"
    t.string   "campus_name"
    t.string   "campus_ipeds_unitid"
    t.string   "csv_accreditation_type"
    t.string   "agency_name",              null: false
    t.string   "last_action"
    t.string   "periods"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "accreditations", ["campus_ipeds_unitid"], name: "index_accreditations_on_campus_ipeds_unitid", using: :btree
  add_index "accreditations", ["campus_name"], name: "index_accreditations_on_campus_name", using: :btree
  add_index "accreditations", ["institution_ipeds_unitid"], name: "index_accreditations_on_institution_ipeds_unitid", using: :btree
  add_index "accreditations", ["institution_name"], name: "index_accreditations_on_institution_name", using: :btree

  create_table "arf_gibills", force: :cascade do |t|
    t.string   "facility_code",           null: false
    t.string   "institution",             null: false
    t.string   "total_count_of_students", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "arf_gibills", ["facility_code"], name: "index_arf_gibills_on_facility_code", unique: true, using: :btree
  add_index "arf_gibills", ["institution"], name: "index_arf_gibills_on_institution", using: :btree

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

  add_index "eight_keys", ["city"], name: "index_eight_keys_on_city", using: :btree
  add_index "eight_keys", ["cross"], name: "index_eight_keys_on_cross", using: :btree
  add_index "eight_keys", ["institution"], name: "index_eight_keys_on_institution", using: :btree
  add_index "eight_keys", ["ope"], name: "index_eight_keys_on_ope", using: :btree
  add_index "eight_keys", ["state"], name: "index_eight_keys_on_state", using: :btree

  create_table "p911_tfs", force: :cascade do |t|
    t.string   "facility_code",     null: false
    t.string   "institution",       null: false
    t.string   "p911_tuition_fees", null: false
    t.string   "p911_recipients",   null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "p911_tfs", ["facility_code"], name: "index_p911_tfs_on_facility_code", unique: true, using: :btree
  add_index "p911_tfs", ["institution"], name: "index_p911_tfs_on_institution", using: :btree

  create_table "p911_yrs", force: :cascade do |t|
    t.string   "facility_code",      null: false
    t.string   "institution",        null: false
    t.string   "p911_yellow_ribbon", null: false
    t.string   "p911_yr_recipients", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "p911_yrs", ["facility_code"], name: "index_p911_yrs_on_facility_code", unique: true, using: :btree
  add_index "p911_yrs", ["institution"], name: "index_p911_yrs_on_institution", using: :btree

  create_table "scorecards", force: :cascade do |t|
    t.string   "cross",                       null: false
    t.string   "ope",                         null: false
    t.string   "institution"
    t.string   "insturl"
    t.string   "pred_degree_awarded"
    t.string   "locale"
    t.string   "undergrad_enrollment"
    t.string   "retention_all_students_ba"
    t.string   "retention_all_students_otb"
    t.string   "salary_all_students"
    t.string   "repayment_rate_all_students"
    t.string   "avg_stu_loan_debt"
    t.string   "c150_4_pooled_supp"
    t.string   "c200_l4_pooled_supp"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "scorecards", ["cross"], name: "index_scorecards_on_cross", using: :btree
  add_index "scorecards", ["institution"], name: "index_scorecards_on_institution", using: :btree
  add_index "scorecards", ["ope"], name: "index_scorecards_on_ope", using: :btree

  create_table "sec702s", force: :cascade do |t|
    t.string   "state",      null: false
    t.string   "sec_702",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sec702s", ["state"], name: "index_sec702s_on_state", unique: true, using: :btree

  create_table "svas", force: :cascade do |t|
    t.string   "institution",          null: false
    t.string   "cross"
    t.string   "city"
    t.string   "state"
    t.string   "student_veteran_link"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "svas", ["cross"], name: "index_svas_on_cross", using: :btree
  add_index "svas", ["institution"], name: "index_svas_on_institution", using: :btree

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

  create_table "vsocs", force: :cascade do |t|
    t.string   "facility_code",    null: false
    t.string   "institution",      null: false
    t.string   "vetsuccess_name"
    t.string   "vetsuccess_email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "vsocs", ["facility_code"], name: "index_vsocs_on_facility_code", unique: true, using: :btree
  add_index "vsocs", ["institution"], name: "index_vsocs_on_institution", using: :btree

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
