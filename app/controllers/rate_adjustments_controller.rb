# frozen_string_literal: true

class RateAdjustmentsController < ApplicationController
  include CollectionUpdatable

  def update
    # Iterate over collection and update records if changes present
    @updated = update_collection
    @rate_adjustments = RateAdjustment.by_chapter_number
    @calculator_constants = CalculatorConstant.all 

    respond_to do |format|
      format.turbo_stream { render template: 'calculator_constants/update' }
    end
  end
end
