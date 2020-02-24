# frozen_string_literal: true

module V0
  class YellowRibbonProgramsController < ApiController
    include Facets

    # GET /v0/yellow_ribbon_programs?name=duluth
    def index
      @meta = {
        version: @version,
        count: search_results.count
      }
      render json: search_results.order('school_name_in_yr_database ASC NULLS LAST').page(params[:page]), meta: @meta
    end

    private

    def normalized_query_params
      query = params.deep_dup
      query.tap do
        query[:name].try(:strip!)
        query[:name].try(:downcase!)
      end
    end

    def search_results
      @query ||= normalized_query_params
      YellowRibbonProgramSource.search(@query[:name])
    end
  end
end
