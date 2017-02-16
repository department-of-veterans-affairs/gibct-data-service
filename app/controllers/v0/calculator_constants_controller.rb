# frozen_string_literal: true
module V0
  class CalculatorConstantsController < ApiController
    # GET /v0/calculator/constants
    def index
      response = {
        data: CalculatorConstant.version(params[:version]).all,
        links: {
          self: v0_calculator_constants_url(version: params[:version])
        },
        meta: {
          version: params[:version]
        }
      }
      render json: response
    end
  end
end
