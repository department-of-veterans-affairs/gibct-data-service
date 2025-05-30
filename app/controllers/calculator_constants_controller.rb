# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  include CollectionUpdatable

  def index
    @calculator_constants = CalculatorConstant.all
    @cost_of_living_adjustments = CostOfLivingAdjustment.by_chapter_number
  end

  def update
    # iterate over collection and update records if changes present
    updated_ids = update_collection

    unless updated_ids.empty?
      # convert ids to associated record names
      updated_names = updated_ids.map { |id| CalculatorConstant.find(id).name }
      flash[:success] = {
        updated_fields: updated_names
      }
    end
    redirect_to action: :index
  end

  def apply_colas
    CalculatorConstant.subject_to_cola.each(&:apply_cola)
  end
end
