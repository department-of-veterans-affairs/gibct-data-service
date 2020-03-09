# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    upload = Upload.where(csv_type: 'CalculatorConstant', ok: true).order(updated_at: :desc).first
    params.each do |key, value|
      next unless CalculatorConstant.exists?(name: key)

      constant_field = CalculatorConstant.where(name: key).first
      constant_field.update(float_value: value)
      update_calculator_constant_upload(upload, constant_field.updated_at)
    end
    flash.notice = 'Calculator Constants have been updated.'
    redirect_to action: :index
  end
end

private

def update_calculator_constant_upload(upload, updated_timestamp)
  if updated_timestamp > upload.updated_at
    upload.update(updated_at: updated_timestamp, created_at: updated_timestamp,
                  completed_at: updated_timestamp, user: current_user)
  end
end
