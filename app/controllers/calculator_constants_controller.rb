# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  include CollectionUpdatable

  def index
    @calculator_constants = CalculatorConstant.all
    @cost_of_living_adjustments = CostOfLivingAdjustment.by_chapter_number
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

  # Apply cost of living adjustments to associated constants
  def apply_colas
    updated = CalculatorConstant.subject_to_cola.each(&:apply_cola)
    flash[:success] = {
      updated_fields: updated.pluck(:name)
    }
    redirect_to action: :index
  end

  # Copy current year (:float_value) to previous year's value (:previous_year)
  def generate_fiscal_year
    CalculatorConstant.find_each do |constant|
      constant.update(previous_year: constant.float_value)
    end
    flash[:success] = {
      message: 'New fiscal year generated.'
    }
    redirect_to action: :index
  end

  def export
    respond_to do |format|
      format.csv { send_data CalculatorConstant.export, type: 'text/csv', filename: 'CalculatorConstant.csv' }
    end
  rescue ActionController::UnknownFormat => e
    log_error(e)
  end

  private

  def log_error(err)
    Rails.logger.error(err.message + err&.backtrace.to_s)
    redirect_to action: :index
  end
end
