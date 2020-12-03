class AddCoordinatesToScorecard < ActiveRecord::Migration[5.2]
  def change
    add_column :scorecards, :latitude, :float
    add_column :scorecards, :longitude, :float
  end
end
