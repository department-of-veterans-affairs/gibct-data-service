# frozen_string_literal: true

class CalculatorConstantsController < ApplicationController
  def index
    @calculator_constants = CalculatorConstant.all
  end

  def update
    params.each do |key, value|
      CalculatorConstant.where(name: key).first.update(float_value: value) if CalculatorConstant.exists?(name: key)
    end
    flash.notice = 'Calculator Constants have been updated'
    redirect_to action: :index
  end
end
