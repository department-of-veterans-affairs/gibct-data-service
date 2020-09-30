class AddRatingFieldsToInstitutionsArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions_archives, :rating_count, :integer
    add_column :institutions_archives, :rating_average, :float
  end
end
