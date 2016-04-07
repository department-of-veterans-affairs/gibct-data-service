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

      # Ipeds Ic Ay
      t.integer :tuition_in_state, default: nil
      t.integer :tuition_out_of_state, default: nil
      t.integer :books, default: nil

      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
      t.index :ope 
      t.index :cross
    end
  end
end
