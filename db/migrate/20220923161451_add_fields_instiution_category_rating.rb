class AddFieldsInstiutionCategoryRating < ActiveRecord::Migration[6.1]
  def change
	add_column :institution_category_ratings, :instructor_knowledge, :integer, default: 0
	add_column :institution_category_ratings, :instructor_engagement, :integer, default: 0
	add_column :institution_category_ratings, :course_material_support, :integer, default: 0
	add_column :institution_category_ratings, :succesful_learning_experience, :integer, default: 0
	add_column :institution_category_ratings, :contribution_career_learning_experience, :integer, default: 0
	add_column :institution_category_ratings, :interact_school_officials, :integer, default: 0
	add_column :institution_category_ratings, :support_school_officials, :integer, default: 0
	add_column :institution_category_ratings, :avail_school_officials, :integer, default: 0
	add_column :institution_category_ratings, :timely_completion_docs, :integer, default: 0
	add_column :institution_category_ratings, :helpfulness_school, :integer, default: 0
	add_column :institution_category_ratings, :extent_support_school, :integer, default: 0
	add_column :institution_category_ratings, :extent_support_others, :integer, default: 0
	add_column :institution_category_ratings, :overall_learning_experience, :integer, default: 0
	add_column :institution_category_ratings, :overall_school_experience, :integer, default: 0
  end
end
