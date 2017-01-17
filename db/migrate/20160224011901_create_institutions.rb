class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :institution_type_name, default: nil

      # Phyiscal Info
      t.string :facility_code, default: nil # String with null as no_data
      t.string :institution, default: nil # String with null as no_data
      t.string :city, default: nil # String with null as no_data
      t.string :state, default: nil # String with null as no_data
      t.string :zip, default: nil # String with null as no_data
      t.string :country, default: nil # String with null as no_data

      # School Metrics
      t.float :bah, default: nil # Float with "null" string values
      t.string :cross, default: nil # String with "null" string values
      t.string :ope, default: nil # String with null as no_data
      t.string :insturl, default: nil # String with null as no_data
      t.string :vet_tuition_policy_url, default: nil # String with null as no_data
      t.integer :pred_degree_awarded, default: nil # Integer with "null" string values
      t.integer :locale, default: nil # Integer with "null" string values
      t.integer :gibill, default: 0
      t.integer :undergrad_enrollment, default: nil # Integer with "null" string values
      t.boolean :yr, default: false
      t.boolean :student_veteran, default: false
      t.string :student_veteran_link, default: nil
      t.boolean :poe, default: false
      t.boolean :eight_keys, default: false
      t.boolean :dodmou, default: false
      t.boolean :sec_702, default: false
      t.string :vetsuccess_name, default: nil # String with "null" string values
      t.string :vetsuccess_email, default: nil # String with "null" string values
      t.string :credit_for_mil_training, default: nil # Boolean with null string values
      t.string :vet_poc, default: nil # Boolean with null string value
      t.string :student_vet_grp_ipeds, default: nil # Boolean with null string values
      t.string :soc_member, default: nil # Boolean with null string values
      t.string :va_highest_degree_offered, default: nil # string with "null" string values
      t.float :retention_rate_veteran_ba, default: nil #Float with "null" strings.
      t.float :retention_all_students_ba, default: nil #Float with "null" strings.
      t.float :retention_rate_veteran_otb, default: nil #Float with "null" strings.
      t.float :retention_all_students_otb, default: nil #Float with "null" strings.
      t.float :persistance_rate_veteran_ba, default: nil #Float with "null" strings.
      t.float :persistance_rate_veteran_otb, default: nil #Float with "null" strings.
      t.float :graduation_rate_veteran, default: nil #Float with "null" strings.
      t.float :graduation_rate_all_students, default: nil #Float with "null" strings.
      t.float :transfer_out_rate_veteran, default: nil #Float with "null" strings.
      t.float :transfer_out_rate_all_students, default: nil #Float with "null" strings.
      t.float :salary_all_students, default: nil #Float with "null" and other terms
      t.float :repayment_rate_all_students, default: nil #Float with "null" and other terms
      t.float :avg_stu_loan_debt, default: nil #Float with "null" and other terms
      t.string :calendar, default: nil # String with "null" string values
      t.float :tuition_in_state, default: nil #Float with "null" and other terms
      t.float :tuition_out_of_state, default: nil #Float with "null" and other terms
      t.float :books, default: nil #Float with "null" and other terms
      t.string :online_all, default: nil # Boolean with null string values
      t.float :p911_tuition_fees, default: 0.0
      t.integer :p911_recipients, default: 0
      t.float :p911_yellow_ribbon, default: 0.0
      t.integer :p911_yr_recipients, default: 0
      t.boolean :accredited, default: false
      t.string :accreditation_type, default: nil # String with "null" string values
      t.string :accreditation_status, default: nil # String with "null" string values
      t.string :caution_flag, default: nil # Boolean with null string values
      t.string :caution_flag_reason, default: nil # String with "null" string values

      # Complaint Data
      t.integer :complaints_facility_code, default: 0
      t.integer :complaints_financial_by_fac_code, default: 0
      t.integer :complaints_quality_by_fac_code, default: 0
      t.integer :complaints_refund_by_fac_code, default: 0
      t.integer :complaints_marketing_by_fac_code, default: 0
      t.integer :complaints_accreditation_by_fac_code, default: 0
      t.integer :complaints_degree_requirements_by_fac_code, default: 0
      t.integer :complaints_student_loans_by_fac_code, default: 0
      t.integer :complaints_grades_by_fac_code, default: 0
      t.integer :complaints_credit_transfer_by_fac_code, default: 0
      t.integer :complaints_credit_job_by_fac_code, default: 0
      t.integer :complaints_job_by_fac_code, default: 0
      t.integer :complaints_transcript_by_fac_code, default: 0
      t.integer :complaints_other_by_fac_code, default: 0
      t.integer :complaints_main_campus_roll_up, default: 0
      t.integer :complaints_financial_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_quality_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_refund_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_marketing_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_accreditation_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_degree_requirements_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_student_loans_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_grades_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_credit_transfer_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_jobs_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_transcript_by_ope_id_do_not_sum, default: 0
      t.integer :complaints_other_by_ope_id_do_not_sum, default: 0

      t.timestamps null: false

      t.index :facility_code
      t.index :institution_type_name
      t.index :institution
      t.index :city
      t.index :state
    end
  end
end

__END__
# Below is the old schema.rb output from the original GIBCT app

create_table "institution_types", force: :cascade do |t|
  t.string   "name",       null: false
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end

add_index "institution_types", ["name"], name: "index_institution_types_on_name", unique: true, using: :btree

create_table "institutions", force: :cascade do |t|
  t.integer  "institution_type_id"
  t.string   "facility_code"
  t.string   "institution"
  t.string   "city"
  t.string   "state"
  t.string   "zip"
  t.string   "country"
  t.float    "bah"
  t.string   "cross"
  t.string   "ope"
  t.string   "insturl"
  t.string   "vet_tuition_policy_url"
  t.integer  "pred_degree_awarded"
  t.integer  "locale"
  t.integer  "gibill",                                              default: 0
  t.integer  "undergrad_enrollment"
  t.boolean  "yr",                                                  default: false
  t.boolean  "student_veteran",                                     default: false
  t.string   "student_veteran_link"
  t.boolean  "poe",                                                 default: false
  t.boolean  "eight_keys",                                          default: false
  t.boolean  "dodmou",                                              default: false
  t.boolean  "sec_702",                                             default: false
  t.string   "vetsuccess_name"
  t.string   "vetsuccess_email"
  t.string   "credit_for_mil_training"
  t.string   "vet_poc"
  t.string   "student_vet_grp_ipeds"
  t.string   "soc_member"
  t.string   "va_highest_degree_offered"
  t.float    "retention_rate_veteran_ba"
  t.float    "retention_all_students_ba"
  t.float    "retention_rate_veteran_otb"
  t.float    "retention_all_students_otb"
  t.float    "persistance_rate_veteran_ba"
  t.float    "persistance_rate_veteran_otb"
  t.float    "graduation_rate_veteran"
  t.float    "graduation_rate_all_students"
  t.float    "transfer_out_rate_veteran"
  t.float    "transfer_out_rate_all_students"
  t.float    "salary_all_students"
  t.float    "repayment_rate_all_students"
  t.float    "avg_stu_loan_debt"
  t.string   "calendar"
  t.float    "tuition_in_state"
  t.float    "tuition_out_of_state"
  t.float    "books"
  t.string   "online_all"
  t.float    "p911_tuition_fees",                                   default: 0.0
  t.integer  "p911_recipients",                                     default: 0
  t.float    "p911_yellow_ribbon",                                  default: 0.0
  t.integer  "p911_yr_recipients",                                  default: 0
  t.boolean  "accredited",                                          default: false
  t.string   "accreditation_type"
  t.string   "accreditation_status"
  t.string   "caution_flag"
  t.string   "caution_flag_reason"
  t.integer  "complaints_facility_code",                            default: 0
  t.integer  "complaints_financial_by_fac_code",                    default: 0
  t.integer  "complaints_quality_by_fac_code",                      default: 0
  t.integer  "complaints_refund_by_fac_code",                       default: 0
  t.integer  "complaints_marketing_by_fac_code",                    default: 0
  t.integer  "complaints_accreditation_by_fac_code",                default: 0
  t.integer  "complaints_degree_requirements_by_fac_code",          default: 0
  t.integer  "complaints_student_loans_by_fac_code",                default: 0
  t.integer  "complaints_grades_by_fac_code",                       default: 0
  t.integer  "complaints_credit_transfer_by_fac_code",              default: 0
  t.integer  "complaints_credit_job_by_fac_code",                   default: 0
  t.integer  "complaints_job_by_fac_code",                          default: 0
  t.integer  "complaints_transcript_by_fac_code",                   default: 0
  t.integer  "complaints_other_by_fac_code",                        default: 0
  t.integer  "complaints_main_campus_roll_up",                      default: 0
  t.integer  "complaints_financial_by_ope_id_do_not_sum",           default: 0
  t.integer  "complaints_quality_by_ope_id_do_not_sum",             default: 0
  t.integer  "complaints_refund_by_ope_id_do_not_sum",              default: 0
  t.integer  "complaints_marketing_by_ope_id_do_not_sum",           default: 0
  t.integer  "complaints_accreditation_by_ope_id_do_not_sum",       default: 0
  t.integer  "complaints_degree_requirements_by_ope_id_do_not_sum", default: 0
  t.integer  "complaints_student_loans_by_ope_id_do_not_sum",       default: 0
  t.integer  "complaints_grades_by_ope_id_do_not_sum",              default: 0
  t.integer  "complaints_credit_transfer_by_ope_id_do_not_sum",     default: 0
  t.integer  "complaints_jobs_by_ope_id_do_not_sum",                default: 0
  t.integer  "complaints_transcript_by_ope_id_do_not_sum",          default: 0
  t.integer  "complaints_other_by_ope_id_do_not_sum",               default: 0
  t.datetime "created_at",                                                          null: false
  t.datetime "updated_at",                                                          null: false
end

add_index "institutions", ["city"], name: "index_institutions_on_city", using: :btree
add_index "institutions", ["facility_code"], name: "index_institutions_on_facility_code", using: :btree
add_index "institutions", ["institution"], name: "index_institutions_on_institution", using: :btree
add_index "institutions", ["institution_type_id"], name: "index_institutions_on_institution_type_id", using: :btree
add_index "institutions", ["state"], name: "index_institutions_on_state", using: :btree
