class CreateCensusLatLongs < ActiveRecord::Migration[6.0]
  def change
    create_table :census_lat_longs do |t|
      t.string :record_id_number
      t.string :input_address
      t.string :tiger_address_range_match_indicator
      t.string :tiger_match_type
      t.string :tiger_output_address
      t.string :interpolated_longitude_latitude
      t.string :tiger_line_id
      t.string :tiger_line_id_side

      t.timestamps
    end
  end
end
