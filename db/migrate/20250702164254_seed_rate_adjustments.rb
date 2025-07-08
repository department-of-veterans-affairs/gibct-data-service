class SeedRateAdjustments < ActiveRecord::Migration[7.1]
  def up
    SeedUtils.seed_table_with_yaml(RateAdjustment)
    # Associate calculator constants with rate adjustment
    CalculatorConstant.all.each(&:set_rate_adjustment_if_exists)
  end

  def down
    # Must trigger dependent: nullify, therefore don't use #delete_all
    RateAdjustment.destroy_all
  end
end