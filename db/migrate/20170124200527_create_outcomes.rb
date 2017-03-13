class CreateOutcomes < ActiveRecord::Migration
  def change
    create_table :outcomes do |t|
      # Used in the building of DataCsv
      t.string :facility_code, null: false

      t.float :retention_rate_veteran_ba
      t.float :retention_rate_veteran_otb
      t.float :persistance_rate_veteran_ba
      t.float :persistance_rate_veteran_otb
      t.float :graduation_rate_veteran
      t.float :transfer_out_rate_veteran

      # Not used in building DataCsv, but used in exporting source csv
      t.string :institution
      t.string :school_level_va

      t.timestamps null: false

      t.index :facility_code, unique: true
    end
  end
end
