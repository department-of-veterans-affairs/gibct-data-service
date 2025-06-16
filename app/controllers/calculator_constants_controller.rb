# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  include CollectionUpdatable

  before_action :set_rate_adjustment_id, only: :apply_rate_adjustments

  def index
    @calculator_constants = CalculatorConstant.all
    @rate_adjustments = RateAdjustment.by_chapter_number
  end

  def update
    # Iterate over collection and update records if changes present
    updated = update_collection(&:name)

    unless updated.empty?
      flash[:success] = {
        updated_fields: updated
      }
    end
    redirect_to action: :index
  end

  # Apply rate adjustments to associated constants
  def apply_rate_adjustments
    updated = CalculatorConstant.by_rate_adjustment(@rate_adjustment_id)
                                .each(&:apply_rate_adjustment)
    flash[:success] = {
      updated_fields: updated.pluck(:name)
    }
    redirect_to action: :index
  end

  private

  def set_rate_adjustment_id
    @rate_adjustment_id = params.require(:rate_adjustment_id)
  end
end
