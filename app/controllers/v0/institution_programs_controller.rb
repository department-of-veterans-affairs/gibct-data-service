# frozen_string_literal: true

module V0
  class InstitutionProgramsController < ApiController
    include Search::Facets

    # GET /v0/institution_programs/autocomplete?term=harv
    def autocomplete
      @data = []
      if params[:term].present?
        @search_term = params[:term]&.strip&.downcase
        @data = autocomplete_results(@search_term, @version)
      end
      @meta = {
        version: @version,
        term: @search_term
      }
      @links = { self: self_link }
      render json: { data: @data, meta: @meta, links: @links }, adapter: :json
    end

    # GET /v0/institution_programs?name=duluth&x=y
    def index
      @meta = {
        version: @version,
        count: search_results.count,
        facets: facets
      }

      render json: search_results
        .search_order(@query)
        .then { |results| pagination_for(results) },
        meta: @meta
    end

    private

    def normalized_query_params
      query = params.deep_dup
      query.tap do
        query[:name].try(:strip!)
        query[:name].try(:downcase!)
        query[:preferred_provider].try(:downcase!)
        query[:disable_pagination].try(:downcase!)
        query[:provider].try(:upcase!)
        %i[state country type].each do |k|
          query[k].try(:upcase!)
        end
      end
    end

    def search_results
      @query ||= normalized_query_params
      if Institution.state_search_term?(@query[:name])
        relation = InstitutionProgram.joins(institution: :version)
                                     .eager_load(:institution)
                                     .where(institutions: { version: @version, state: @query[:name].upcase })
      elsif Institution.city_state_search_term?(@query[:name])
        terms = @query[:name].split(',').map(&:strip)
        relation = InstitutionProgram.joins(institution: :version)
                                     .eager_load(:institution)
                                     .where(institutions: { version: @version, city: terms[0].upcase,
                                                            state: terms[1].upcase })
      else
        relation = InstitutionProgram.joins(institution: :version)
                                     .where(institutions: { version: @version })
                                     .eager_load(:institution)
                                     .search(@query)
      end
      filter_results(relation)
    end

    # Given a search term representing a partial school name, returns all
    # programs starting with the search term.
    def autocomplete_results(search_term, version, limit = 6)
      filter_results(
        InstitutionProgram.select(:id, 'institutions.facility_code as value', 'description as label')
        .joins(institution: :version)
        .where(institutions: { version: version })
      )
        .where('lower(description) LIKE (?)', "#{search_term}%")
        .limit(limit)
    end

    def filter_results(relation)
      @query ||= normalized_query_params
      [
        %i[program_type type],
        %i[institutions.institution provider],
        %i[institutions.facility_code facility_code],
        %w[institutions.physical_country country],
        %w[institutions.physical_state state],
        %w[institutions.preferred_provider preferred_provider]
      ].each do |filter_args|
        relation = relation.filter_result(filter_args[0], @query[filter_args[1]])
      end

      if @query[:exclude_warnings]
        relation = relation.where('institutions.count_of_caution_flags = 0  AND institutions.school_closing IS FALSE')
      end
      relation = relation.where(institutions: { count_of_caution_flags: 0 }) if @query[:exclude_caution_flags]
      relation
    end

    def facets
      result = {
        type: search_results.filter_count(:program_type),
        state: search_results.filter_count('institutions.physical_state'),
        provider: embed(search_results.filter_count('institutions.institution')),
        country: embed(search_results.filter_count('institutions.physical_country'))
      }

      add_active_search_facets(result)
    end

    def add_active_search_facets(raw_facets)
      add_search_facet(raw_facets, :type)
      add_search_facet(raw_facets, :state)
      add_country_search_facet(raw_facets)
      raw_facets
    end

    def pagination_for(results)
      @query[:disable_pagination] == 'true' ? results : results.page(page)
    end
  end
end
