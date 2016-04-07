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

ActiveRecord::Schema.define(version: 20160330160605) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accreditations", force: :cascade do |t|
    t.string   "institution_name"
    t.string   "campus_name"
    t.string   "institution"
    t.string   "ope"
    t.string   "ope6"
    t.string   "institution_ipeds_unitid"
    t.string   "campus_ipeds_unitid"
    t.string   "cross"
    t.string   "csv_accreditation_type"
    t.string   "accreditation_type"
    t.string   "agency_name",              null: false
    t.string   "accreditation_status"
    t.string   "periods"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "accreditations", ["cross"], name: "index_accreditations_on_cross", using: :btree
  add_index "accreditations", ["institution"], name: "index_accreditations_on_institution", using: :btree
  add_index "accreditations", ["ope"], name: "index_accreditations_on_ope", using: :btree
  add_index "accreditations", ["ope6"], name: "index_accreditations_on_ope6", using: :btree

  create_table "arf_gibills", force: :cascade do |t|
    t.string   "facility_code", null: false
    t.string   "institution"
    t.integer  "gibill",        null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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

  create_table "data_csvs", force: :cascade do |t|
    t.string   "facility_code",                                  null: false
    t.string   "institution",                                    null: false
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "va_highest_degree_offered"
    t.string   "type"
    t.integer  "bah"
    t.boolean  "poe"
    t.boolean  "yr"
    t.boolean  "flight"
    t.boolean  "correspondence"
    t.boolean  "accredited"
    t.string   "ope"
    t.string   "ope6"
    t.string   "cross"
    t.boolean  "student_veteran",                default: false
    t.string   "student_veteran_link"
    t.string   "vetsuccess_name"
    t.string   "vetsuccess_email"
    t.boolean  "eight_keys"
    t.string   "accreditation_status"
    t.string   "accreditation_type"
    t.integer  "gibill"
    t.float    "p911_tuition_fees"
    t.integer  "p911_recipients"
    t.float    "p911_yellow_ribbon"
    t.integer  "p911_yr_recipients"
    t.boolean  "dodmou"
    t.string   "insturl"
    t.integer  "pred_degree_awarded"
    t.integer  "locale"
    t.integer  "undergrad_enrollment"
    t.float    "retention_all_students_ba"
    t.float    "retention_all_students_otb"
    t.float    "graduation_rate_all_students"
    t.float    "transfer_out_rate_all_students"
    t.float    "salary_all_students"
    t.float    "repayment_rate_all_students"
    t.float    "avg_stu_loan_debt"
    t.string   "credit_for_mil_training"
    t.string   "vet_poc"
    t.string   "student_vet_grp_ipeds"
    t.string   "soc_member"
    t.string   "calendar"
    t.string   "online_all"
    t.string   "vet_tuition_policy_url"
    t.integer  "tuition_in_state"
    t.integer  "tuition_out_of_state"
    t.integer  "books"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "data_csvs", ["cross"], name: "index_data_csvs_on_cross", using: :btree
  add_index "data_csvs", ["facility_code"], name: "index_data_csvs_on_facility_code", unique: true, using: :btree
  add_index "data_csvs", ["institution"], name: "index_data_csvs_on_institution", using: :btree
  add_index "data_csvs", ["ope"], name: "index_data_csvs_on_ope", using: :btree

  create_table "eight_keys", force: :cascade do |t|
    t.string   "institution"
    t.string   "cross"
    t.string   "ope"
    t.string   "ope6"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "eight_keys", ["cross"], name: "index_eight_keys_on_cross", using: :btree
  add_index "eight_keys", ["institution"], name: "index_eight_keys_on_institution", using: :btree
  add_index "eight_keys", ["ope"], name: "index_eight_keys_on_ope", using: :btree
  add_index "eight_keys", ["ope6"], name: "index_eight_keys_on_ope6", using: :btree

  create_table "hcms", force: :cascade do |t|
    t.string   "ope",            null: false
    t.string   "institution",    null: false
    t.string   "city"
    t.string   "state"
    t.string   "monitor_method", null: false
    t.string   "reason",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "hcms", ["institution"], name: "index_hcms_on_institution", using: :btree
  add_index "hcms", ["ope"], name: "index_hcms_on_ope", using: :btree

  create_table "ipeds_hds", force: :cascade do |t|
    t.string   "cross",                  null: false
    t.string   "vet_tuition_policy_url"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "ipeds_hds", ["cross"], name: "index_ipeds_hds_on_cross", using: :btree

  create_table "ipeds_ic_ays", force: :cascade do |t|
    t.string   "cross",                null: false
    t.integer  "tuition_in_state"
    t.integer  "tuition_out_of_state"
    t.integer  "books"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "ipeds_ic_ays", ["cross"], name: "index_ipeds_ic_ays_on_cross", using: :btree

  create_table "ipeds_ic_pies", force: :cascade do |t|
    t.string   "cross",                null: false
    t.integer  "chg1py3"
    t.integer  "tuition_in_state"
    t.integer  "tuition_out_of_state"
    t.integer  "books"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "ipeds_ic_pies", ["cross"], name: "index_ipeds_ic_pies_on_cross", using: :btree

  create_table "ipeds_ics", force: :cascade do |t|
    t.string   "cross",                   null: false
    t.integer  "vet2",                    null: false
    t.integer  "vet3",                    null: false
    t.integer  "vet4",                    null: false
    t.integer  "vet5",                    null: false
    t.integer  "calsys",                  null: false
    t.integer  "distnced",                null: false
    t.string   "credit_for_mil_training"
    t.string   "vet_poc"
    t.string   "student_vet_grp_ipeds"
    t.string   "soc_member"
    t.string   "calendar"
    t.string   "online_all"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "ipeds_ics", ["cross"], name: "index_ipeds_ics_on_cross", using: :btree

  create_table "mous", force: :cascade do |t|
    t.string   "ope",         null: false
    t.string   "ope6",        null: false
    t.string   "institution"
    t.string   "status"
    t.boolean  "dodmou"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "mous", ["institution"], name: "index_mous_on_institution", using: :btree
  add_index "mous", ["ope"], name: "index_mous_on_ope", using: :btree

  create_table "p911_tfs", force: :cascade do |t|
    t.string   "facility_code",     null: false
    t.string   "institution"
    t.float    "p911_tuition_fees", null: false
    t.integer  "p911_recipients",   null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "p911_tfs", ["facility_code"], name: "index_p911_tfs_on_facility_code", unique: true, using: :btree
  add_index "p911_tfs", ["institution"], name: "index_p911_tfs_on_institution", using: :btree

  create_table "p911_yrs", force: :cascade do |t|
    t.string   "facility_code",      null: false
    t.string   "institution"
    t.float    "p911_yellow_ribbon", null: false
    t.integer  "p911_yr_recipients", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "p911_yrs", ["facility_code"], name: "index_p911_yrs_on_facility_code", unique: true, using: :btree
  add_index "p911_yrs", ["institution"], name: "index_p911_yrs_on_institution", using: :btree

  create_table "scorecards", force: :cascade do |t|
    t.string   "cross",                          null: false
    t.string   "ope",                            null: false
    t.string   "ope6",                           null: false
    t.string   "institution"
    t.string   "insturl"
    t.integer  "pred_degree_awarded"
    t.integer  "locale"
    t.integer  "undergrad_enrollment"
    t.float    "retention_all_students_ba"
    t.float    "retention_all_students_otb"
    t.float    "graduation_rate_all_students"
    t.float    "transfer_out_rate_all_students"
    t.float    "salary_all_students"
    t.float    "repayment_rate_all_students"
    t.float    "avg_stu_loan_debt"
    t.float    "c150_4_pooled_supp"
    t.float    "c200_l4_pooled_supp"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "scorecards", ["cross"], name: "index_scorecards_on_cross", using: :btree
  add_index "scorecards", ["institution"], name: "index_scorecards_on_institution", using: :btree
  add_index "scorecards", ["ope"], name: "index_scorecards_on_ope", using: :btree

  create_table "sec702_schools", force: :cascade do |t|
    t.string   "facility_code", null: false
    t.string   "sec_702",       null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "sec702_schools", ["facility_code"], name: "index_sec702_schools_on_facility_code", unique: true, using: :btree

  create_table "sec702s", force: :cascade do |t|
    t.string   "state",      null: false
    t.string   "sec_702",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sec702s", ["state"], name: "index_sec702s_on_state", unique: true, using: :btree

  create_table "settlements", force: :cascade do |t|
    t.string   "cross",                  null: false
    t.string   "institution",            null: false
    t.string   "settlement_description", null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "settlements", ["cross"], name: "index_settlements_on_cross", using: :btree
  add_index "settlements", ["institution"], name: "index_settlements_on_institution", using: :btree

  create_table "svas", force: :cascade do |t|
    t.string   "institution"
    t.string   "cross"
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
    t.string   "institution"
    t.string   "cross"
    t.string   "ope"
    t.string   "ope6"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "va_crosswalks", ["cross"], name: "index_va_crosswalks_on_cross", using: :btree
  add_index "va_crosswalks", ["facility_code"], name: "index_va_crosswalks_on_facility_code", unique: true, using: :btree
  add_index "va_crosswalks", ["institution"], name: "index_va_crosswalks_on_institution", using: :btree
  add_index "va_crosswalks", ["ope"], name: "index_va_crosswalks_on_ope", using: :btree
  add_index "va_crosswalks", ["ope6"], name: "index_va_crosswalks_on_ope6", using: :btree

  create_table "vsocs", force: :cascade do |t|
    t.string   "facility_code",    null: false
    t.string   "institution"
    t.string   "vetsuccess_name"
    t.string   "vetsuccess_email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "vsocs", ["facility_code"], name: "index_vsocs_on_facility_code", unique: true, using: :btree
  add_index "vsocs", ["institution"], name: "index_vsocs_on_institution", using: :btree

  create_table "weams", force: :cascade do |t|
    t.string   "facility_code",                            null: false
    t.string   "institution",                              null: false
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "va_highest_degree_offered"
    t.string   "type"
    t.integer  "bah"
    t.boolean  "poe"
    t.boolean  "yr"
    t.boolean  "flight"
    t.boolean  "correspondence"
    t.boolean  "accredited"
    t.string   "poo_status"
    t.string   "applicable_law_code"
    t.boolean  "institution_of_higher_learning_indicator"
    t.boolean  "ojt_indicator"
    t.boolean  "correspondence_indicator"
    t.boolean  "flight_indicator"
    t.boolean  "non_college_degree_indicator"
    t.boolean  "approved",                                 null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "weams", ["approved"], name: "index_weams_on_approved", using: :btree
  add_index "weams", ["facility_code"], name: "index_weams_on_facility_code", unique: true, using: :btree
  add_index "weams", ["institution"], name: "index_weams_on_institution", using: :btree

end
