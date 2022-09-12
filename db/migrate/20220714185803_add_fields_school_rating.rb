class AddFieldsSchoolRating < ActiveRecord::Migration[6.1]
  def change
  	add_column :school_ratings, :email_address, :string
	add_column :school_ratings, :age, :string
	add_column :school_ratings, :gender, :string
	add_column :school_ratings, :school, :string
	add_column :school_ratings, :degree, :string
	add_column :school_ratings, :graduation_date, :datetime
	add_column :school_ratings, :benefit_program, :string
	add_column :school_ratings, :enrollment_type, :string
	add_column :school_ratings, :monthly_payments_benefit, :string
	add_column :school_ratings, :payee_number, :string
	add_column :school_ratings, :objective_code, :string
	add_column :school_ratings, :survey_sent_date, :datetime
	add_column :school_ratings, :instructor_knowledge, :integer, default: 0
	add_column :school_ratings, :instructor_engagement, :integer, default: 0
	add_column :school_ratings, :course_material_support, :integer, default: 0
	add_column :school_ratings, :succesful_learning_experience, :integer, default: 0
	add_column :school_ratings, :contribution_career_learning_experience, :integer, default: 0
	add_column :school_ratings, :interact_school_officials, :integer, default: 0
	add_column :school_ratings, :support_school_officials, :integer, default: 0
	add_column :school_ratings, :avail_school_officials, :integer, default: 0
	add_column :school_ratings, :timely_completion_docs, :integer, default: 0
	add_column :school_ratings, :helpfulness_school, :integer, default: 0
	add_column :school_ratings, :extent_support_school, :integer, default: 0
	add_column :school_ratings, :extent_support_others, :integer, default: 0
	add_column :school_ratings, :overall_learning_experience, :integer, default: 0
	add_column :school_ratings, :overall_school_experience, :integer, default: 0
  end
end