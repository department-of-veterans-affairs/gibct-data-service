class RemoveAfsRatingsTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :institution_category_ratings, if_exists: true
    drop_table :institution_category_ratings_archives, if_exists: true
    drop_table :school_ratings, if_exists: true
  end
end
