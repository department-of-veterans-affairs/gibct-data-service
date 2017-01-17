# frozen_string_literal: true
module V0
  class CalculatorConstantsController < ApiController
    # GET /v0/calculator/constants
    def index
      render json: CalculatorConstant.all
    end
  end
end
