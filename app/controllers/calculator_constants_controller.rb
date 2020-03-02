class CalculatorConstantsController < ApplicationController
  def index
      @calculator_constants = CalculatorConstant.version(@version).all
  end
end
