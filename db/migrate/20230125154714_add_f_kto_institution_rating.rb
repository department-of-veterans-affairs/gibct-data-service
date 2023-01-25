class AddFKtoInstitutionRating < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :institution_ratings, :institutions, column: :institution_id, validate: false
  end
end
