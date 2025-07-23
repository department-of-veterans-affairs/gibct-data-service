# frozen_string_literal: true

module V0
  class CalculatorConstantsController < ApiController
    # GET /v0/calculator/constants
    def index
      # TODO: implement actual versioning
      @data = CalculatorConstant.version(@version).all
      @links = { self: self_link }
      @meta = { version: @version }
      render json: @data, meta: @meta, links: @links
    end
  end
end
