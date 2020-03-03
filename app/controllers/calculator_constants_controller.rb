class CalculatorConstantsController < ApplicationController
  def index
      @calculator_constants = CalculatorConstant.version(@version).all
  end

  def update
    params.each do |key, value|
      if CalculatorConstant.exists?(name: key)
        CalculatorConstant.where(name: key).first.update(float_value: value)
      end
    end
    flash.notice = 'Calculator Constants have been updated'
    redirect_to action: :index
  end
end
