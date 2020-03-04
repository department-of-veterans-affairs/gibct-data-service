# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    upload = Upload.where(csv_type: 'CalculatorConstant').first
    params.each do |key, value|
      next unless CalculatorConstant.exists?(name: key)

      constant_field = CalculatorConstant.where(name: key).first
      constant_field.update(float_value: value)
      update_upload_timestamp(upload, constant_field.updated_at)
    end
    flash.notice = 'Calculator Constants have been updated.'
    redirect_to action: :index
  end
end

private

def update_upload_timestamp(upload, updated_timestamp)
  upload.update(updated_at: updated_timestamp, created_at: updated_timestamp) if updated_timestamp > upload.updated_at
end
