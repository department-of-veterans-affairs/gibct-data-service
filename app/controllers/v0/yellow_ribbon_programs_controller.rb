# frozen_string_literal: true

module V0
  class YellowRibbonProgramsController < ApiController
    include Search::Facets

    # GET /v0/yellow_ribbon_programs
    # ?page=1
    # &per_page=30
    # &sort_by=number_of_students
    # &sort_direction=desc
    # &city=boulder
    # &country=usa
    # &contribution_amount=unlimited
    # &number_of_students=unlimited
    # &name=university
    # &state=co
    def index
      @meta = {
        version: @version,
        count: search_results.count
      }
      per_page = params[:per_page] || search_results.per_page
      render json: search_results.page(params[:page]).per_page(per_page.to_i), meta: @meta
    end

    private

    def normalized_query_params
      query = params.deep_dup
      query.tap do
        # Filtering query params.
        query[:city].try(:strip!)
        query[:city].try(:downcase!)

        query[:country].try(:strip!)
        query[:country].try(:downcase!)

        query[:contribution_amount].try(:strip!)
        query[:contribution_amount].try(:downcase!)

        query[:number_of_students].try(:strip!)
        query[:number_of_students].try(:downcase!)

        query[:name].try(:strip!)
        query[:name].try(:downcase!)

        query[:state].try(:strip!)
        query[:state].try(:downcase!)

        # Sorting query params.
        query[:sort_by].try(:strip!)
        query[:sort_by].try(:downcase!)

        query[:sort_direction].try(:strip!)
        query[:sort_direction].try(:downcase!)
      end
    end

    def search_results
      @query ||= normalized_query_params

      # Derive the search results.
      results = YellowRibbonProgram.version(@version).search(@query)

      # Derive the order properties.
      order_properties = {}
      order_properties[sanitized_sort_by] = sanitized_sort_direction

      # Sort the results.
      results.order(order_properties)
    end

    def sanitized_sort_by
      YellowRibbonProgram.new.attributes.include?(@query[:sort_by]) ? @query[:sort_by] : :institution
    end

    def sanitized_sort_direction
      return :desc if @query[:sort_direction] == 'desc'

      :asc
    end
  end
end
