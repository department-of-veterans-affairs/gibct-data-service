class AddNoGeocodeMatchInstitutionArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :institutions_archives, :no_geocode_match, :boolean, default: false
  end
end
