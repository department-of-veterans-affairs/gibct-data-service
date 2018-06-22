# frozen_string_literal: true

module V0
  class ZipcodeRatesController < ApiController
    skip_before_action :resolve_version
    # GET /v0/housing_rates/20001
    def show
      resource = ZipcodeRate.find_by(zip_code: params[:id])
      raise Common::Exceptions::RecordNotFound, params[:id] unless resource

      render json: resource, serializer: ZipcodeRateSerializer
    end
  end
end
