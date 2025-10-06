# frozen_string_literal: true

class RateAdjustmentsController < ApplicationController
  include CollectionUpdatable

  before_action :process_marked_for_destroy, only: [:update], prepend: true
  before_action :process_marked_for_create, only: [:update], prepend: true

  def update
    # Iterate over collection and update records if changes present
    @updated = update_collection
    @rate_adjustments = RateAdjustment.by_chapter_number
    @calculator_constants = CalculatorConstant.all

    respond_to do |format|
      format.turbo_stream { render template: 'calculator_constants/update_rate_adjustments' }
    end
  end

  def build
    byebug
  end

  private

  # Destroy records and remove from collection params
  def process_marked_for_destroy
    return unless params[:marked_for_destroy].present?

    params[:marked_for_destroy].each do |rate_id|
      RateAdjustment.find(rate_id).destroy
      params[:rate_adjustments].delete(rate_id)
      params[:marked_for_create]&.delete(rate_id)
    end
  end

  def process_marked_for_create
    return unless params[:marked_for_create].present?

    params[:marked_for_create].each do |rate_id|
      rate_params = params[:rate_adjustments].delete(rate_id)
                                             .permit(%i[rate benefit_type])
      RateAdjustment.create(rate_params)
    end
  end
end
