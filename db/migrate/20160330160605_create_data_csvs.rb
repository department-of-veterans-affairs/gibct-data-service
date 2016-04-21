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
      t.boolean :eight_keys, default: nil
      
      # Accreditations
      t.string :accreditation_status, default: nil
      t.string :accreditation_type, default: nil

      # Arf Gibill
      t.integer :gibill, default: nil

      # P911 Tf
      t.float :p911_tuition_fees, default: nil
      t.integer :p911_recipients, default: nil

      # P911 Yr
      t.float :p911_yellow_ribbon, default: nil
      t.integer :p911_yr_recipients, default: nil

      # Dod Mou
      t.boolean :dodmou, default: nil

      # Scorecard
      t.string :insturl, default: nil
      t.integer :pred_degree_awarded, default: nil
      t.integer :locale, default: nil
      t.integer :undergrad_enrollment, default: nil
      t.float :retention_all_students_ba, default: nil
      t.float :retention_all_students_otb, default: nil
      t.float :graduation_rate_all_students, default: nil
      t.float :transfer_out_rate_all_students, default: nil
      t.float :salary_all_students, default: nil
      t.float :repayment_rate_all_students, default: nil
      t.float :avg_stu_loan_debt, default: nil

      # Ipeds Ic
      t.string :credit_for_mil_training, default: nil
      t.string :vet_poc, default: nil
      t.string :student_vet_grp_ipeds, default: nil
      t.string :soc_member, default: nil
      t.string :calendar, default: nil
      t.string :online_all, default: nil

      # Ipeds Hd
      t.string :vet_tuition_policy_url, default: nil

      # Ipeds Ic Ay/Py
      t.integer :tuition_in_state, default: nil
      t.integer :tuition_out_of_state, default: nil
      t.integer :books, default: nil

      # Sec702/Sec702 School
      t.boolean :sec_702, default: nil

      # Mou/Accreditation/Settlement/Hcm
      t.boolean :caution_flag, default: nil
      t.text :caution_flag_reason, default: nil

      # Complaint
      t.integer :complaints_facility_code, default: nil
      t.integer :complaints_financial_by_fac_code, default: nil
      t.integer :complaints_quality_by_fac_code, default: nil
      t.integer :complaints_refund_by_fac_code, default: nil
      t.integer :complaints_marketing_by_fac_code, default: nil
      t.integer :complaints_accreditation_by_fac_code, default: nil
      t.integer :complaints_degree_requirements_by_fac_code, default: nil
      t.integer :complaints_student_loans_by_fac_code, default: nil
      t.integer :complaints_grades_by_fac_code, default: nil
      t.integer :complaints_credit_transfer_by_fac_code, default: nil
      t.integer :complaints_job_by_fac_code, default: nil
      t.integer :complaints_transcript_by_fac_code, default: nil
      t.integer :complaints_other_by_fac_code, default: nil

      t.integer :complaints_main_campus_roll_up, default: nil
      t.integer :complaints_financial_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_quality_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_refund_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_marketing_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_accreditation_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_degree_requirements_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_student_loans_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_grades_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_credit_transfer_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_jobs_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_transcript_by_ope_id_do_not_sum, default: nil
      t.integer :complaints_other_by_ope_id_do_not_sum, default: nil     

      # Outcome
      t.float :retention_rate_veteran_ba, default: nil
      t.float :retention_rate_veteran_otb, default: nil
      t.float :persistance_rate_veteran_ba, default: nil
      t.float :persistance_rate_veteran_otb, default: nil
      t.float :graduation_rate_veteran, default: nil
      t.float :transfer_out_rate_veteran, default: nil

      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
      t.index :ope 
      t.index :cross
    end
  end
end
