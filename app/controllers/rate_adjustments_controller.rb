# frozen_string_literal: true

class RateAdjustmentsController < ApplicationController
  include CollectionUpdatable

  def update
    process_marked_for_destroy
    process_marked_for_create
    # Iterate over collection and update records if changes present
    update_collection
    @rate_adjustments = RateAdjustment.by_chapter_number
    @calculator_constants = CalculatorConstant.all

    render template: 'calculator_constants/update_rate_adjustments'
  end

  def build
    @rate_adjustment = RateAdjustment.new(build_params)
    
    respond_to do |format|
      format.turbo_stream { render template: 'calculator_constants/build_rate_adjustment' }
    end
  end

  private

  # Destroy records and remove from collection params
  def process_marked_for_destroy
    return unless params[:marked_for_destroy].present?

    params[:marked_for_destroy].each do |rate_id|
      @collection_params.delete(rate_id)
      RateAdjustment.find(rate_id).destroy
    end
  end

  # Create records and remove from collection params
  def process_marked_for_create
    return unless params[:marked_for_create].present?

    params[:marked_for_create].each do |new_rate|
      id = new_rate[:id]
      rate = params.dig(:rate_adjustments, id, :rate)
      benefit_type = new_rate[:benefit_type]
      RateAdjustment.create(rate:, benefit_type:)
    end
  end

  def build_params
    params.permit(:benefit_type).merge(rate: 0.0)
  end
end
