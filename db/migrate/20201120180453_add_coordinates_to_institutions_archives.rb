class AddCoordinatesToInstitutionsArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions_archives, :latitude, :float
    add_column :institutions_archives, :longitud, :float
  end
end
