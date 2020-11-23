class AddCoordinatesToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :latitude, :float
    add_column :institutions, :longitud, :float
  end
end
