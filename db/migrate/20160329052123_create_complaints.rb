class CreateComplaints < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.string :facility_code
      t.string :ope 
      t.string :ope6
      t.string :institution
      t.string :status
      t.string :closed_reason
      t.string :issue

      t.integer :cfc, default: 0
      t.integer :cfbfc, default: 0
      t.integer :cqbfc, default: 0
      t.integer :crbfc, default: 0
      t.integer :cmbfc, default: 0
      t.integer :cabfc, default: 0
      t.integer :cdrbfc, default: 0
      t.integer :cslbfc, default: 0
      t.integer :cgbfc, default: 0
      t.integer :cctbfc, default: 0
      t.integer :cjbfc, default: 0
      t.integer :ctbfc, default: 0
      t.integer :cobfc, default: 0

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
      t.index :ope 
      t.index :ope6
      t.index :institution
    end
  end
end
