# frozen_string_literal: true

module V0
  class ZipcodeRatesController < ApiController
    # GET /v0/zipcode_rates/20001
    def show
      resource = ZipcodeRate.where(version: @version[:number], zip_code: params[:id]).order(:mha_rate).first

      raise Common::Exceptions::RecordNotFound, params[:id] unless resource

      render json: resource, serializer: ZipcodeRateSerializer
    end
  end
end
