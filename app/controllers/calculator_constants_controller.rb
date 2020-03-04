# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    calculator_constant_upload = Upload.where(csv_type: 'CalculatorConstant').first
    params.each do |key, value|
      next unless CalculatorConstant.exists?(name: key)

      constant_field = CalculatorConstant.where(name: key).first
      constant_field.update(float_value: value)
      updated_timestamp = constant_field.updated_at
      if updated_timestamp > calculator_constant_upload.updated_at
        calculator_constant_upload.update(updated_at: updated_timestamp, created_at: updated_timestamp)
      end
    end
    flash.notice = 'Calculator Constants have been updated'
    redirect_to action: :index
  end
end
