# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  include CollectionUpdatable

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
    updated = CalculatorConstant.subject_to_rate_adjustment.each(&:apply_rate_adjustment)
    flash[:success] = {
      updated_fields: updated.pluck(:name)
    }
    redirect_to action: :index
  end
end
