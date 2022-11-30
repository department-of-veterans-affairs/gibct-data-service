class AddFieldsInstCategoryArchives < ActiveRecord::Migration[6.1]
  def change
  	add_column :institution_category_ratings_archives, :instructor_knowledge, :integer, default: 0
	add_column :institution_category_ratings_archives, :instructor_engagement, :integer, default: 0
	add_column :institution_category_ratings_archives, :course_material_support, :integer, default: 0
	add_column :institution_category_ratings_archives, :succesful_learning_experience, :integer, default: 0
	add_column :institution_category_ratings_archives, :contribution_career_learning_experience, :integer, default: 0
	add_column :institution_category_ratings_archives, :interact_school_officials, :integer, default: 0
	add_column :institution_category_ratings_archives, :support_school_officials, :integer, default: 0
	add_column :institution_category_ratings_archives, :avail_school_officials, :integer, default: 0
	add_column :institution_category_ratings_archives, :timely_completion_docs, :integer, default: 0
	add_column :institution_category_ratings_archives, :helpfulness_school, :integer, default: 0
	add_column :institution_category_ratings_archives, :extent_support_school, :integer, default: 0
	add_column :institution_category_ratings_archives, :extent_support_others, :integer, default: 0
	add_column :institution_category_ratings_archives, :overall_learning_experience, :integer, default: 0
	add_column :institution_category_ratings_archives, :overall_school_experience, :integer, default: 0
  end
end
