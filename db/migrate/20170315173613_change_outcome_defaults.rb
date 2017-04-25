class ChangeOutcomeDefaults < ActiveRecord::Migration
  def change
    change_table :outcomes do |t|
      t.change :retention_rate_veteran_ba, :float, default: nil
      t.change :retention_rate_veteran_otb, :float, default: nil
      t.change :persistance_rate_veteran_ba, :float, default: nil
      t.change :persistance_rate_veteran_otb, :float, default: nil
      t.change :graduation_rate_veteran, :float, default: nil
      t.change :transfer_out_rate_veteran, :float, default: nil
    end
  end
end
