# frozen_string_literal: true

module V0
  class InstitutionsController < ApiController
    include Search::Facets

    # GET /v0/institutions/autocomplete?term=harv
    def autocomplete
      @data = []
      if params[:term].present?
        @query ||= normalized_query_params
        @search_term = params[:term]&.strip&.downcase
        @data = filter_results(Institution.non_vet_tec_institutions(@version)).autocomplete(@search_term)
      end
      @meta = {
        version: @version,
        term: @search_term
      }
      @links = { self: self_link }
      render json: { data: @data, meta: @meta, links: @links }, adapter: :json
    end

    # GET /v0/institutions?name=duluth&x=y
    def index
      @query ||= normalized_query_params
      @meta = {
        version: @version,
        count: search_results.count,
        facets: facets
      }

      # For sorting by percentage instead whole number
      max_gibill = Institution.non_vet_tec_institutions(@version).maximum(:gibill) || 0
      search_term = @query[:name]

      # Weighted sort is not needed when not using Institution scope search
      if Institution.state_search_term?(search_term) || Institution.city_state_search_term?(search_term)

        render json: search_results.city_state_search_order(max_gibill)
                                   .page(page), meta: @meta
      else
        render json: search_results.search_order(@query, max_gibill)
                                   .page(page), meta: @meta
      end
    end

    # GET /v0/institutions/20005123
    def show
      resource = Institution.approved_institutions(@version).find_by(facility_code: params[:id])

      raise Common::Exceptions::Internal::RecordNotFound, params[:id] unless resource

      @links = { self: self_link }
      render json: resource, serializer: InstitutionProfileSerializer,
             meta: { version: @version }, links: @links
    end

    # GET /v0/institutions/20005123/children
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
        query[:name].try(:downcase!)
        %i[state country type].each do |k|
          query[k].try(:upcase!)
        end
        %i[category student_veteran_group yellow_ribbon_scholarship principles_of_excellence
           eight_keys_to_veteran_success stem_offered independent_study priority_enrollment
           online_only distance_learning].each do |k|
          query[k].try(:downcase!)
        end
      end
    end

    def search_results
      @query ||= normalized_query_params
      if Institution.state_search_term?(@query[:name])
        relation = Institution.non_vet_tec_institutions(@version)
                              .where(state: @query[:name].upcase)
      elsif Institution.city_state_search_term?(@query[:name])
        terms = @query[:name].upcase.split(',').map(&:strip)
        relation = Institution.non_vet_tec_institutions(@version)
                              .where({ city: terms[0].upcase, state: terms[1].upcase })
      else
        relation = Institution.non_vet_tec_institutions(@version)
                              .search(@query)
      end
      filter_results(relation)
    end

    def filter_results(relation)
      [
        %i[institution_type_name type],
        [:category],
        [:country],
        [:state],
        %i[student_veteran student_veteran_group], # boolean
        %i[yr yellow_ribbon_scholarship], # boolean
        %i[poe principles_of_excellence], # boolean
        %i[eight_keys eight_keys_to_veteran_success], # boolean
        [:stem_offered], # boolean
        [:independent_study], # boolean
        [:online_only],
        [:distance_learning],
        [:priority_enrollment], # boolean
        [:preferred_provider], # boolean
        [:stem_indicator], # boolean
        [:womenonly], # boolean
        [:menonly], # boolean
        [:hbcu], # boolean
        [:relaffil],
        [:hsi], # boolean
        [:nanti], # boolean
        [:annhi], # boolean
        [:aanapii], # boolean
        [:pbi], # boolean
        [:tribal] # boolean
      ].each do |filter_args|
        filter_args << filter_args[0] if filter_args.size == 1
        relation = relation.filter_result(filter_args[0], @query[filter_args[1]])
      end

      relation = relation.where('count_of_caution_flags = 0 AND school_closing IS FALSE') if @query[:exclude_warnings]
      relation = relation.where(count_of_caution_flags: 0) if @query[:exclude_caution_flags]

      relation
    end

    # TODO: If filter counts are desired in the future, change boolean facets
    # to use search_results.filter_count(param) instead of default value
    def facets
      institution_types = search_results.filter_count(:institution_type_name)
      result = {
        category: {
          school: institution_types.except(Institution::EMPLOYER).inject(0) { |count, (_t, n)| count + n },
          employer: institution_types[Institution::EMPLOYER].to_i
        },
        type: institution_types,
        state: search_results.filter_count(:state),
        country: embed(search_results.filter_count(:country)),
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
        relaffil: search_results.filter_count(:relaffil),
        hsi: boolean_facet,
        nanti: boolean_facet,
        annhi: boolean_facet,
        aanapii: boolean_facet,
        pbi: boolean_facet,
        tribal: boolean_facet
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
