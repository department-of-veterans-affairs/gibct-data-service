# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    upload = Upload.where(csv_type: 'CalculatorConstant').first
    calculator_constant = CalculatorConstant.find(params[:id])
    calculator_constant.update(float_value: params[:updated_value])
    update_upload_timestamp(upload, calculator_constant.updated_at)
    flash.notice = 'TheCalculator Constant: ' + calculator_constant.name + ' has been updated.'
    redirect_to action: :index
  end

  private
  def update_upload_timestamp(upload, updated_timestamp)
    upload.update(updated_at: updated_timestamp, created_at: updated_timestamp) if updated_timestamp > upload.updated_at
  end
end