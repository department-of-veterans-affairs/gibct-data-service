class CreateInstitutionRatings < ActiveRecord::Migration[6.1]
  def change
    create_table :institution_ratings do |t|
      t.integer :institution_id
      t.decimal :q1_avg, precision: 2, scale: 1
      t.integer :q1_count
      t.decimal :q2_avg, precision: 2, scale: 1
      t.integer :q2_count
      t.decimal :q3_avg, precision: 2, scale: 1
      t.integer :q3_count
      t.decimal :q4_avg, precision: 2, scale: 1
      t.integer :q4_count
      t.decimal :q5_avg, precision: 2, scale: 1
      t.integer :q5_count
      t.decimal :q7_avg, precision: 2, scale: 1
      t.integer :q7_count
      t.decimal :q8_avg, precision: 2, scale: 1
      t.integer :q8_count
      t.decimal :q9_avg, precision: 2, scale: 1
      t.integer :q9_count
      t.decimal :q10_avg, precision: 2, scale: 1
      t.integer :q10_count
      t.decimal :q11_avg, precision: 2, scale: 1
      t.integer :q11_count
      t.decimal :q12_avg, precision: 2, scale: 1
      t.integer :q12_count
      t.decimal :q13_avg, precision: 2, scale: 1
      t.integer :q13_count
      t.decimal :q14_avg, precision: 2, scale: 1
      t.integer :q14_count
      t.decimal :q15_avg, precision: 2, scale: 1
      t.integer :q15_count
      t.decimal :q16_avg, precision: 2, scale: 1
      t.integer :q16_count
      t.decimal :q17_avg, precision: 2, scale: 1
      t.integer :q17_count
      t.decimal :q18_avg, precision: 2, scale: 1
      t.integer :q18_count
      t.decimal :q19_avg, precision: 2, scale: 1
      t.integer :q19_count
      t.decimal :q20_avg, precision: 2, scale: 1
      t.integer :q20_count

      t.decimal :m1_avg, precision: 2, scale: 1
      t.decimal :m2_avg, precision: 2, scale: 1
      t.decimal :m3_avg, precision: 2, scale: 1
      t.decimal :m4_avg, precision: 2, scale: 1
      t.decimal :m5_avg, precision: 2, scale: 1
      t.decimal :m6_avg, precision: 2, scale: 1
      t.decimal :m7_avg, precision: 2, scale: 1

      t.decimal :overall_avg, precision: 2, scale: 1
      t.integer :institution_rating_count
    end

    add_index :institution_ratings, :institution_id, unique: true 
  end
end
