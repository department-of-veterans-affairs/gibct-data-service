class ChangeInstitutionDefaults < ActiveRecord::Migration[4.2]
  def change
    change_table :institutions do |t|
      t.change :flight, :boolean, default: nil
      t.change :correspondence, :boolean, default: nil
      t.change :gibill, :integer, default: nil
      t.change :yr, :boolean, default: nil
      t.change :student_veteran, :boolean, default: nil
      t.change :poe, :boolean, default: nil
      t.change :eight_keys, :boolean, default: nil
      t.change :dodmou, :boolean, default: nil
      t.change :p911_tuition_fees, :float, default: nil
      t.change :p911_recipients, :integer, default: nil
      t.change :p911_yellow_ribbon, :float, default: nil
      t.change :p911_yr_recipients, :integer, default: nil
      t.change :accredited, :boolean, default: nil
      t.change :caution_flag, :boolean, default: nil

      t.change :complaints_facility_code, :integer, default: nil
      t.change :complaints_financial_by_fac_code, :integer, default: nil
      t.change :complaints_quality_by_fac_code, :integer, default: nil
      t.change :complaints_refund_by_fac_code, :integer, default: nil
      t.change :complaints_marketing_by_fac_code, :integer, default: nil
      t.change :complaints_accreditation_by_fac_code, :integer, default: nil
      t.change :complaints_degree_requirements_by_fac_code, :integer, default: nil
      t.change :complaints_student_loans_by_fac_code, :integer, default: nil
      t.change :complaints_grades_by_fac_code, :integer, default: nil
      t.change :complaints_credit_transfer_by_fac_code, :integer, default: nil
      t.change :complaints_credit_job_by_fac_code, :integer, default: nil
      t.change :complaints_job_by_fac_code, :integer, default: nil
      t.change :complaints_transcript_by_fac_code, :integer, default: nil
      t.change :complaints_other_by_fac_code, :integer, default: nil
      t.change :complaints_main_campus_roll_up, :integer, default: nil
      t.change :complaints_financial_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_quality_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_refund_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_marketing_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_accreditation_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_degree_requirements_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_student_loans_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_grades_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_credit_transfer_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_jobs_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_transcript_by_ope_id_do_not_sum, :integer, default: nil
      t.change :complaints_other_by_ope_id_do_not_sum, :integer, default: nil
    end
  end
end
