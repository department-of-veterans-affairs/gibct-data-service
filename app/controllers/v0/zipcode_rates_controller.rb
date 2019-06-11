# frozen_string_literal: true

module V0
  class ZipcodeRatesController < ApiController
    # GET /v0/zipcode_rates/20001
    def show
      resource = ZipcodeRate.version(@version[:number])
                            .order(:dod_mha_rate)
                            .find_by(zip_code: params[:id])
      raise Common::Exceptions::RecordNotFound, params[:id] unless resource

      render json: resource, serializer: ZipcodeRateSerializer
    end
  end
end
