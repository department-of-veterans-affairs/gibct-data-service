# frozen_string_literal: true

module V1
  class CalculatorConstantsController < ApiController
    # GET /v0/calculator/constants
    def index
      if CalculatorConstant.versioning_enabled?
        # Use the Versioned CalculatorConstant model to get the data
        @version = Version.current_production
        @data = CalculatorConstantVersion.where(version: @version)
        @links = { self: self_link }
        @meta = { version: @version }
        render json: @data,
               each_serializer: CalculatorConstantSerializer,
               meta: @meta,
               links: @links
      else
        @version = Version.current_production
        @data = CalculatorConstant.all
        @links = { self: self_link }
        render json: @data,
               each_serializer: CalculatorConstantSerializer,
               meta: { version: @version },
               links: @links
      end
    end
  end
end
