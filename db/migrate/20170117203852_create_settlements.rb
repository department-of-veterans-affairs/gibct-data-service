class CreateSettlements < ActiveRecord::Migration[4.2]
  def change
    create_table :settlements do |t|
      # Used in the building of DataCsv
      t.string :cross, null: false
      t.string :settlement_description, null: false

      # Not used in building DataCsv, but used in exporting source csv
      t.string :institution
      t.integer :school_system_code
      t.string :school_system_name
      t.string :settlement_date
      t.string :settlement_link
      t.timestamps null: false

      t.index :cross
    end
  end
end
