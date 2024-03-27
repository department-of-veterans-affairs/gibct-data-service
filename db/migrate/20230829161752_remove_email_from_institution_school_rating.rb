class RemoveEmailFromInstitutionSchoolRating < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :institution_school_ratings, :email }
  end
end
