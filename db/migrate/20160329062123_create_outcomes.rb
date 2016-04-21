class CreateOutcomes < ActiveRecord::Migration
  def change
    create_table :outcomes do |t|
      t.string :facility_code, null: false
      t.string :institution
      t.float :retention_rate_veteran_ba, default: 0.00
      t.float :retention_rate_veteran_otb, default: 0.00
      t.float :persistance_rate_veteran_ba, default: 0.00
      t.float :persistance_rate_veteran_otb, default: 0.00
      t.float :graduation_rate_veteran, default: 0.00
      t.float :transfer_out_rate_veteran, default: 0.00

      t.timestamps null: false

      t.index :facility_code
      t.index :institution
    end
  end
end
