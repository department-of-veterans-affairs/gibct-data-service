class CreateScorecards < ActiveRecord::Migration
  def change
    create_table :scorecards do |t|
      t.string :cross, null: false
      t.string :ope, null: false
      t.string :institution
      t.string :insturl
      t.string :pred_degree_awarded
      t.string :locale
      t.string :undergrad_enrollment
      t.string :retention_all_students_ba
      t.string :retention_all_students_otb
      t.string :salary_all_students
      t.string :repayment_rate_all_students
      t.string :avg_stu_loan_debt
      t.string :c150_4_pooled_supp
      t.string :c200_l4_pooled_supp

      t.timestamps null: false

      t.index :institution
      t.index :cross
      t.index :ope
    end
  end
end
