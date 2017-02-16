# frozen_string_literal: true
module V0
  class CalculatorConstantsController < ApiController
    # GET /v0/calculator/constants
    def index
      @version = nil # TODO: params[:version]

      @data = CalculatorConstant.version(@version).all
      @links = { self: v0_calculator_constants_url(version: @version) }
      @meta = { version: @version }
      render json: @data, meta: @meta, links: @links
    end
  end
end
