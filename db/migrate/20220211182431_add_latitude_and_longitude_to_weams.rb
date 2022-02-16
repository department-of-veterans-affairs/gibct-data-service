class AddLatitudeAndLongitudeToWeams < ActiveRecord::Migration[6.1]
  def change
    add_column :weams, :latitude, :float
    add_column :weams, :longitude, :float
  end
end
