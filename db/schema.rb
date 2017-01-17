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

ActiveRecord::Schema.define(version: 20170117134227) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accreditations", force: :cascade do |t|
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
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "accreditations", ["cross"], name: "index_accreditations_on_cross", using: :btree
  add_index "accreditations", ["institution"], name: "index_accreditations_on_institution", using: :btree
  add_index "accreditations", ["ope"], name: "index_accreditations_on_ope", using: :btree
  add_index "accreditations", ["ope6"], name: "index_accreditations_on_ope6", using: :btree

  create_table "arf_gi_bills", force: :cascade do |t|
    t.string   "facility_code",             null: false
    t.integer  "gibill"
    t.integer  "total_paid"
    t.string   "institution"
    t.integer  "station"
    t.integer  "count_of_adv_pay_students"
    t.integer  "count_of_reg_students"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "arf_gi_bills", ["facility_code"], name: "index_arf_gi_bills_on_facility_code", unique: true, using: :btree

  create_table "crosswalks", force: :cascade do |t|
    t.string   "facility_code", null: false
    t.string   "cross"
    t.string   "ope"
    t.string   "ope6"
    t.string   "city"
    t.string   "state"
    t.string   "institution"
    t.string   "notes"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "crosswalks", ["cross"], name: "index_crosswalks_on_cross", unique: true, using: :btree
  add_index "crosswalks", ["facility_code"], name: "index_crosswalks_on_facility_code", unique: true, using: :btree
  add_index "crosswalks", ["institution"], name: "index_crosswalks_on_institution", using: :btree
  add_index "crosswalks", ["ope"], name: "index_crosswalks_on_ope", unique: true, using: :btree
  add_index "crosswalks", ["ope6"], name: "index_crosswalks_on_ope6", using: :btree

  create_table "eight_keys", force: :cascade do |t|
    t.string   "cross"
    t.string   "institution"
    t.string   "city"
    t.string   "state"
    t.string   "ope"
    t.string   "ope6"
    t.string   "notes"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "eight_keys", ["cross"], name: "index_eight_keys_on_cross", unique: true, using: :btree
  add_index "eight_keys", ["institution"], name: "index_eight_keys_on_institution", using: :btree
  add_index "eight_keys", ["ope"], name: "index_eight_keys_on_ope", unique: true, using: :btree
  add_index "eight_keys", ["ope6"], name: "index_eight_keys_on_ope6", using: :btree

  create_table "mous", force: :cascade do |t|
    t.string   "ope",              null: false
    t.string   "ope6",             null: false
    t.string   "status"
    t.boolean  "dodmou"
    t.boolean  "dod_status"
    t.string   "institution"
    t.string   "trade_name"
    t.string   "city"
    t.string   "state"
    t.string   "institution_type"
    t.string   "approval_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "mous", ["ope"], name: "index_mous_on_ope", using: :btree
  add_index "mous", ["ope6"], name: "index_mous_on_ope6", using: :btree

  create_table "p911_tfs", force: :cascade do |t|
    t.string   "facility_code",      null: false
    t.float    "p911_tuition_fees",  null: false
    t.integer  "p911_recipients",    null: false
    t.string   "institution"
    t.string   "state"
    t.string   "country"
    t.string   "profit_status"
    t.string   "type_of_payment"
    t.integer  "number_of_payments"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "p911_tfs", ["facility_code"], name: "index_p911_tfs_on_facility_code", unique: true, using: :btree

  create_table "p911_yrs", force: :cascade do |t|
    t.string   "facility_code",      null: false
    t.float    "p911_yellow_ribbon", null: false
    t.integer  "p911_yr_recipients", null: false
    t.string   "institution"
    t.string   "state"
    t.string   "country"
    t.string   "profit_status"
    t.string   "type_of_payment"
    t.integer  "number_of_payments"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "p911_yrs", ["facility_code"], name: "index_p911_yrs_on_facility_code", unique: true, using: :btree

  create_table "scorecards", force: :cascade do |t|
    t.string   "cross",                        null: false
    t.string   "insturl"
    t.integer  "pred_degree_awarded"
    t.integer  "locale"
    t.integer  "undergrad_enrollment"
    t.float    "retention_all_students_ba"
    t.float    "retention_all_students_otb"
    t.integer  "salary_all_students"
    t.float    "avg_stu_loan_debt"
    t.float    "repayment_rate_all_students"
    t.float    "c150_l4_pooled_supp"
    t.float    "c150_4_pooled_supp"
    t.float    "graduation_rate_all_students"
    t.string   "ope"
    t.string   "ope6"
    t.string   "institution"
    t.string   "city"
    t.string   "state"
    t.string   "npcurl"
    t.integer  "hcm2"
    t.integer  "control"
    t.integer  "hbcu"
    t.integer  "pbi"
    t.integer  "annhi"
    t.integer  "tribal"
    t.integer  "aanapii"
    t.integer  "hsi"
    t.integer  "nanti"
    t.integer  "menonly"
    t.integer  "womenonly"
    t.integer  "relaffil"
    t.integer  "satvr25"
    t.integer  "satvr75"
    t.integer  "satmt25"
    t.integer  "satmt75"
    t.integer  "satwr25"
    t.integer  "satwr75"
    t.integer  "satvrmid"
    t.integer  "satmtmid"
    t.integer  "satwrmid"
    t.integer  "actcm25"
    t.integer  "actcm75"
    t.integer  "acten25"
    t.integer  "acten75"
    t.integer  "actmt25"
    t.integer  "actmt75"
    t.integer  "actwr25"
    t.integer  "actwr75"
    t.integer  "actcmmid"
    t.integer  "actenmid"
    t.integer  "actmtmid"
    t.integer  "actwrmid"
    t.integer  "sat_avg"
    t.integer  "sat_avg_all"
    t.float    "pcip01"
    t.float    "pcip03"
    t.float    "pcip04"
    t.float    "pcip05"
    t.float    "pcip09"
    t.float    "pcip10"
    t.float    "pcip11"
    t.float    "pcip12"
    t.float    "pcip13"
    t.float    "pcip14"
    t.float    "pcip15"
    t.float    "pcip16"
    t.float    "pcip19"
    t.float    "pcip22"
    t.float    "pcip23"
    t.float    "pcip24"
    t.float    "pcip25"
    t.float    "pcip26"
    t.float    "pcip27"
    t.float    "pcip29"
    t.float    "pcip30"
    t.float    "pcip31"
    t.float    "pcip38"
    t.float    "pcip39"
    t.float    "pcip40"
    t.float    "pcip41"
    t.float    "pcip42"
    t.float    "pcip43"
    t.float    "pcip44"
    t.float    "pcip45"
    t.float    "pcip46"
    t.float    "pcip47"
    t.float    "pcip48"
    t.float    "pcip49"
    t.float    "pcip50"
    t.float    "pcip51"
    t.float    "pcip52"
    t.float    "pcip54"
    t.integer  "distanceonly"
    t.float    "ugds_white"
    t.float    "ugds_black"
    t.float    "ugds_hisp"
    t.float    "ugds_asian"
    t.float    "ugds_aian"
    t.float    "ugds_nhpi"
    t.float    "ugds_2mor"
    t.float    "ugds_nra"
    t.float    "ugds_unkn"
    t.float    "pptug_ef"
    t.integer  "curroper"
    t.integer  "npt4_pub"
    t.integer  "npt4_priv"
    t.integer  "npt41_pub"
    t.integer  "npt42_pub"
    t.integer  "npt43_pub"
    t.integer  "npt44_pub"
    t.integer  "npt45_pub"
    t.integer  "npt41_priv"
    t.integer  "npt42_priv"
    t.integer  "npt43_priv"
    t.integer  "npt44_priv"
    t.integer  "npt45_priv"
    t.float    "pctpell"
    t.float    "ret_pt4"
    t.float    "ret_ptl4"
    t.float    "pctfloan"
    t.float    "ug25abv"
    t.float    "gt_25k_p6"
    t.float    "grad_debt_mdn10yr_supp"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "scorecards", ["cross"], name: "index_scorecards_on_cross", unique: true, using: :btree
  add_index "scorecards", ["ope"], name: "index_scorecards_on_ope", unique: true, using: :btree

  create_table "sec702_schools", force: :cascade do |t|
    t.string   "facility_code", null: false
    t.boolean  "sec_702"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "sec702_schools", ["facility_code"], name: "index_sec702_schools_on_facility_code", unique: true, using: :btree

  create_table "sec702s", force: :cascade do |t|
    t.string   "state",           null: false
    t.boolean  "sec_702"
    t.string   "state_full_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "sec702s", ["state"], name: "index_sec702s_on_state", unique: true, using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "svas", force: :cascade do |t|
    t.string   "cross"
    t.string   "student_veteran_link"
    t.integer  "csv_id"
    t.string   "institution"
    t.string   "city"
    t.string   "state"
    t.string   "ipeds_code"
    t.string   "website"
    t.string   "sva_yes"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "svas", ["cross"], name: "index_svas_on_cross", unique: true, using: :btree

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

  create_table "vsocs", force: :cascade do |t|
    t.string   "facility_code",    null: false
    t.string   "vetsuccess_name"
    t.string   "vetsuccess_email"
    t.string   "institution"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "vsocs", ["facility_code"], name: "index_vsocs_on_facility_code", unique: true, using: :btree

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
    t.boolean  "ojt_indicator"
    t.boolean  "correspondence_indicator"
    t.boolean  "flight_indicator"
    t.boolean  "non_college_degree_indicator"
    t.boolean  "institution_of_higher_learning_indicator"
    t.string   "poo_status"
    t.string   "applicable_law_code"
    t.boolean  "approved"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "address_3"
    t.string   "cross"
    t.string   "ope"
    t.string   "ope6"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "weams", ["facility_code"], name: "index_weams_on_facility_code", unique: true, using: :btree
  add_index "weams", ["institution"], name: "index_weams_on_institution", using: :btree
  add_index "weams", ["state"], name: "index_weams_on_state", using: :btree

end
