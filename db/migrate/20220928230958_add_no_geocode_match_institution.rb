class AddNoGeocodeMatchInstitution < ActiveRecord::Migration[6.1]
  def change
    add_column :institutions, :no_geocode_match, :boolean, default: false
  end
end
