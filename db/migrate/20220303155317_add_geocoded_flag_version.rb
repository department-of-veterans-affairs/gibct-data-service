class AddGeocodedFlagVersion < ActiveRecord::Migration[6.1]
  def change
  	add_column :versions, :geocoded, :boolean, default: false
  end
end
