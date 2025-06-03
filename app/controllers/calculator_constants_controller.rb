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
    updated = CalculatorConstant.subject_to_cola.each(&:apply_cola)
    flash[:success] = {
      updated_fields: updated.pluck(:name)
    }
    redirect_to action: :index
  end

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
