class CreateScorecards < ActiveRecord::Migration
  def change
    create_table :scorecards do |t|
      t.string :cross, null: false
      t.string :ope, null: false
      t.string :ope6, null: false
      t.string :institution
      t.string :insturl
      t.integer :pred_degree_awarded
      t.integer :locale
      t.integer :undergrad_enrollment
      t.float :retention_all_students_ba
      t.float :retention_all_students_otb
      t.float :graduation_rate_all_students
      t.float :transfer_out_rate_all_students, default: nil
      t.float :salary_all_students
      t.float :repayment_rate_all_students
      t.float :avg_stu_loan_debt
      t.float :c150_4_pooled_supp
      t.float :c150_l4_pooled_supp

      t.timestamps null: false

      t.index :institution
      t.index :cross
      t.index :ope
    end
  end
end
