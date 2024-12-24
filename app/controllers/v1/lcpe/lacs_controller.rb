class V1::Lcpe::LacsController < ApplicationController
  def index
    results = Lcpe::Lac.with_enriched_id

    render json: results, each_serializer: Lcpe::LacSerializer, adapter: :json, action: 'index'
  end

  def show
    result =
      Lcpe::Lac
        .by_enriched_id(params[:id])
        .includes([:tests, :institution])
        .first

    render json: result, serializer: Lcpe::LacSerializer, adapter: :json, action: 'show'
  end
end
