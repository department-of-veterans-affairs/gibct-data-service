class AddRatingFieldsToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :rating_count, :integer, :default => 0
    add_column :institutions, :rating_average, :float
  end
end
