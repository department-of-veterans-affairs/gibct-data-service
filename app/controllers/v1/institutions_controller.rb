# frozen_string_literal: true

module V1
  class InstitutionsController < ApiController
    include Search::Facets

    # GET /v1/institutions/autocomplete?term=harv
    def autocomplete
      @data = []
      if params[:term].present?
        @query ||= normalized_query_params
        @search_term = params[:term]&.strip&.downcase
        @data = Institution.approved_institutions(@version).filter_result_v1(@query).autocomplete(@search_term)
      end
      @meta = {
        version: @version,
        term: @search_term
      }
      @links = { self: self_link }
      render json: { data: @data, meta: @meta, links: @links }, adapter: :json
    end

    # GET /v1/institutions?name=duluth&location=mn&x=y
    #   Default search
    def index
      @query ||= normalized_query_params

      # For sorting by percentage instead whole number
      max_gibill = Institution.approved_institutions(@version).maximum(:gibill) || 0
      results = Institution.approved_institutions(@version)
                           .search_v1(@query)
                           .filter_result_v1(@query)

      # Apply location filters if location string is provided
      if @query[:location].present?
        location_params = parse_location(@query[:location])
        results = results.where(location_params)
      end

      results = results.search_order_v1(@query, max_gibill).page(page)
      results = results.filter_high_school if @query[:excluded_school_types]&.include?('HIGH SCHOOL')

      @meta = {
        version: @version,
        count: results.count,
        facets: facets(results)
      }

      render json: results,
             each_serializer: InstitutionSearchResultSerializer,
             meta: @meta
    end

    # GET /v1/institutions?latitude=0.0&longitude=0.0
    #   Location search
    def location
      @query ||= normalized_query_params

      # Start with location-based search
      location_results = Institution.approved_institutions(@version)
                                    .location_search(@query)
                                    .filter_result_v1(@query)

      # Add name search if name parameter is present
      location_results = location_results.search_v1(name: @query[:name]) if @query[:name].present?

      results = location_results.location_select(@query).location_order
      results = results.filter_high_school if @query[:excluded_school_types]&.include?('HIGH SCHOOL')

      @meta = {
        version: @version,
        count: location_results.count,
        facets: facets(location_results)
      }

      render json: results,
             each_serializer: InstitutionSearchResultSerializer,
             meta: @meta
    end

    # GET /v1/institutions?facility_codes=1,2,3,4
    #   Search by facility code and return using InstitutionCompareSerializer
    def facility_codes
      @query ||= normalized_query_params

      results = Institution.approved_institutions(@version).where(facility_code: @query[:facility_codes])
                           .order(:institution)

      @meta = {
        version: @version,
        count: results.count
      }

      render json: results,
             each_serializer: InstitutionCompareSerializer,
             meta: @meta
    end

    # GET /v1/institutions/20005123
    def show
      resource = Institution.approved_institutions(@version).find_by(facility_code: params[:id])

      raise Common::Exceptions::Internal::RecordNotFound, params[:id] unless resource

      @links = { self: self_link }
      render json: resource, serializer: InstitutionProfileSerializer,
             meta: { version: @version }, links: @links
    end

    # GET /v1/institutions/20005123/children
    def children
      children = Institution.joins(:version)
                            .where(version: @version)
                            .where(parent_facility_code_id: params[:id])
                            .order(:institution)
                            .page(page)

      @meta = {
        version: @version,
        count: children.count
      }
      @links = { self: self_link }
      render json: children,
             each_serializer: InstitutionSerializer,
             meta: @meta,
             links: @links
    end

    private

    def normalized_query_params
      query = params.deep_dup
      query.tap do
        query[:name].try(:strip!)
        query[:location].try(:strip!)
        %i[state country type].each do |k|
          query[k].try(:upcase!)
        end
        %i[name category student_veteran_group yellow_ribbon_scholarship principles_of_excellence
           eight_keys_to_veteran_success stem_offered independent_study priority_enrollment
           online_only distance_learning location].each do |k|
          query[k].try(:downcase!)
        end
        %i[latitude longitude distance].each do |k|
          query[k] = float_conversion(query[k]) if query[k].present?
        end
      end
    end

    # TODO: If filter counts are desired in the future, change boolean facets
    # to use search_results.filter_count(param) instead of default value
    def parse_location(location)
      return {} if location.blank?

      # Try to parse as city, state format
      if location.include?(',')
        city, state = location.split(',').map(&:strip)
        { city: city.upcase, state: state.upcase }
      # Try to parse as state abbreviation
      elsif location.length == 2
        { state: location.upcase }
      # Try to parse as zip code
      elsif location.match?(/^\d{5}$/)
        { zip: location }
      # Treat as city name
      else
        { city: location.upcase }
      end
    end

    def facets(results)
      result = {
        category: {
          school: results.boolean_filter_count(:school_provider),
          employer: results.boolean_filter_count(:employer_provider)
        },
        state: results.filter_count(:state),
        country: embed(results.filter_count(:country)),
        student_vet_group: boolean_facet,
        yellow_ribbon_scholarship: boolean_facet,
        principles_of_excellence: boolean_facet,
        eight_keys_to_veteran_success: boolean_facet,
        stem_offered: boolean_facet,
        independent_study: boolean_facet,
        online_only: boolean_facet,
        distance_learning: boolean_facet,
        priority_enrollment: boolean_facet,
        menonly: boolean_facet,
        womenonly: boolean_facet,
        hbcu: boolean_facet,
        relaffil: results.filter_count(:relaffil),
        hsi: boolean_facet,
        nanti: boolean_facet,
        annhi: boolean_facet,
        aanapii: boolean_facet,
        pbi: boolean_facet,
        tribal: boolean_facet,
        vet_tec_provider: boolean_facet,
        section_103_message: boolean_facet
      }

      add_active_search_facets(result)
    end

    def add_active_search_facets(raw_facets)
      add_search_facet(raw_facets, :state)
      add_country_search_facet(raw_facets)
      raw_facets
    end
  end
end
