class CreateInstitutionCategoryRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :institution_category_ratings do |t|
      t.string :category_name, null: false
      t.float :average_rating
      t.integer :rated5_count
      t.integer :rated4_count
      t.integer :rated3_count
      t.integer :rated2_count
      t.integer :rated1_count
      t.integer :na_count
      t.integer :institution_id, null: false
      t.index :institution_id
    end
  end
end
