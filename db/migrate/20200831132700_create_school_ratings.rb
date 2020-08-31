class CreateSchoolRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :school_ratings do |t|
      t.string :ranker_id, null: false
      t.string :facility_code, null: false
      t.integer :overall_experience
      t.integer :quality_of_classes
      t.integer :online_instruction
      t.integer :job_preparation
      t.integer :gi_bill_support
      t.integer :veteran_community
      t.integer :marketing_practices
      t.datetime :facility_code, null: false
    end
  end
end
