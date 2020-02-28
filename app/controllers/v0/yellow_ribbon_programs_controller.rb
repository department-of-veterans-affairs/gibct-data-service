# frozen_string_literal: true

module V0
  class YellowRibbonProgramsController < ApiController
    include Facets

    # GET /v0/yellow_ribbon_programs?school_name_in_yr_database=duluth&sort_direction=desc
    def index
      @meta = {
        version: @version,
        count: search_results.count
      }
      render json: search_results.page(params[:page]), meta: @meta
    end

    private

    def normalized_query_params
      query = params.deep_dup
      query.tap do
        query[:school_name_in_yr_database].try(:strip!)
        query[:school_name_in_yr_database].try(:downcase!)
        query[:sort_by].try(:strip!)
        query[:sort_by].try(:downcase!)
        query[:sort_direction].try(:strip!)
        query[:sort_direction].try(:downcase!)
      end
    end

    def search_results
      @query ||= normalized_query_params

      # Derive the search results.
      results = YellowRibbonProgram.search(@query[:school_name_in_yr_database])

      # Derive the order properties.
      order_properties = {}
      order_properties[sanitized_sort_by] = sanitized_sort_direction

      # Sort the results.
      results.order(order_properties)
    end

    def sanitized_sort_by
      YellowRibbonProgram.last.attributes.include?(@query[:sort_by]) ? @query[:sort_by] : :school_name_in_yr_database
    end

    def sanitized_sort_direction
      return :desc if @query[:sort_direction] == 'desc'

      :asc
    end
  end
end
