class CreateCostOfLivingAdjustmentRecords < ActiveRecord::Migration[7.1]
  def up
    CostOfLivingAdjustment::BENEFIT_TYPES.each do |benefit_type|
      CostOfLivingAdjustment.create(benefit_type: benefit_type, rate: 0)
    end
  end

  def down
    CostOfLivingAdjustment.destroy_all
  end
end
