# frozen_string_literal: true

module V0
  class CalculatorConstantsController < ApiController
    # GET /v0/calculator/constants
    def index
      # Use the Versioned CalculatorConstant model to get the data
      @data = CalculatorConstantVersion.where(version: @version)
      @links = { self: self_link }
      @meta = { version: @version }
      render json: @data,
              each_serializer: CalculatorConstantSerializer,
              meta: @meta,
              links: @links
    end
  end
end
