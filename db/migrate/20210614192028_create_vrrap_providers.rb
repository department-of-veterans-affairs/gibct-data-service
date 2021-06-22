class CreateVrrapProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :vrrap_providers do |t|
      t.string :school_name
      t.string :facility_code
      t.string :programs
      t.boolean :vaco
      t.string :address
    end
  end
end
