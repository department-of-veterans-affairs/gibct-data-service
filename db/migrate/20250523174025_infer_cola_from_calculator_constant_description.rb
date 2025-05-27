class InferColaFromCalculatorConstantDescription < ActiveRecord::Migration[7.1]
  # Iterate through existing CalculatorConstants and associate with CostOfLivingAdjustment
  # if description column references COLA benefit type

  def up
    CalculatorConstant.all.each do |constant|
      constant.set_cola_if_exists
    end
  end

  def down
    CalculatorConstant.update_all(cost_of_living_adjustment_id: nil)
  end
end
