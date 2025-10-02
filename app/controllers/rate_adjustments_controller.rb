# frozen_string_literal: true

class RateAdjustmentsController < ApplicationController
  include CollectionUpdatable

  def update
    process_marked_for_destroy
    # Iterate over collection and update records if changes present
    @updated = update_collection
    @rate_adjustments = RateAdjustment.by_chapter_number
    @calculator_constants = CalculatorConstant.all

    respond_to do |format|
      format.turbo_stream { render template: 'calculator_constants/update_rate_adjustments' }
    end
  end

  private

  # Destroy records and remove from collection params
  def process_marked_for_destroy
    params[:marked_for_destroy].each do |rate_id|
      RateAdjustment.find(rate_id).destroy
      @collection_params.delete(rate_id)
    end
  end
end
