# frozen_string_literal: true

class CostOfLivingAdjustmentsController < ApplicationController
  def update
    updated_fields = []
    cola_collection_params.each do |benefit_type, new_rate|
      CostOfLivingAdjustment.find_by(benefit_type:)&.then do |cola|
        if cola.rate != new_rate.to_d
          cola.update(rate: new_rate)
          updated_fields.push("Chapter #{benefit_type}")
        end
      end
    end
  end

  private

  def cola_collection_params
    params.require(:cost_of_living_adjustments).permit(*CostOfLivingAdjustment::BENEFIT_TYPES)
  end
end
