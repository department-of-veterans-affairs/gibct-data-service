# frozen_string_literal: true

module V1
  class InstitutionsController < ApiController
    include Facets

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

    # GET /v1/institutions?name=duluth&x=y
    #   Default search
    def index
      @query ||= normalized_query_params

      # For sorting by percentage instead whole number
      max_gibill = Institution.approved_institutions(@version).maximum(:gibill) || 0
      results = Institution.approved_institutions(@version)
                    .search_v1(@query)
                    .filter_result_v1(@query)
                    .search_order(@query, max_gibill).page(page)

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

      location_results = Institution.approved_institutions(@version).location_search(@query).filter_result_v1(@query)
      results = location_results.location_select(@query).location_order

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

      raise Common::Exceptions::RecordNotFound, params[:id] unless resource

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
    def facets(results)
      institution_types = results.filter_count(:institution_type_name)
      result = {
        category: {
          school: institution_types.except(Institution::EMPLOYER).inject(0) { |count, (_t, n)| count + n },
          employer: institution_types[Institution::EMPLOYER].to_i
        },
        type: institution_types,
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
        vet_tec_provider: boolean_facet
      }

      add_active_search_facets(result)
    end

    def add_active_search_facets(raw_facets)
      add_search_facet(raw_facets, :state)
      add_search_facet(raw_facets, :type)
      add_country_search_facet(raw_facets)
      raw_facets
    end
  end
end
