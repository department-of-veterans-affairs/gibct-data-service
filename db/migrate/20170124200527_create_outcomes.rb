class CreateOutcomes < ActiveRecord::Migration
  def change
    create_table :outcomes do |t|
      # Used in the building of DataCsv
      t.string :facility_code, null: false

      t.float :retention_rate_veteran_ba, default: 0.00
      t.float :retention_rate_veteran_otb, default: 0.00
      t.float :persistance_rate_veteran_ba, default: 0.00
      t.float :persistance_rate_veteran_otb, default: 0.00
      t.float :graduation_rate_veteran, default: 0.00
      t.float :transfer_out_rate_veteran, default: 0.00

      # Not used in building DataCsv, but used in exporting source csv
      t.string :institution
      t.string :school_level_va
      
      t.timestamps null: false

      t.index :facility_code, unique: true
    end
  end
end
