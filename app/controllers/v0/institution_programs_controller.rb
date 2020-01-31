# frozen_string_literal: true

module V0
  class InstitutionProgramsController < ApiController
    include Facets

    # GET /v0/institution_programs/autocomplete?term=harv
    def autocomplete
      @data = []
      if params[:term].present?
        @search_term = params[:term]&.strip&.downcase
        @data = InstitutionProgram.version(@version[:number]).autocomplete(@search_term)
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
        .order('institutions.preferred_provider DESC NULLS LAST, institutions.institution')
        .page(params[:page]), meta: @meta
    end

    private

    def normalized_query_params
      query = params.deep_dup
      query.tap do
        query[:name].try(:strip!)
        query[:name].try(:downcase!)
        query[:provider].try(:upcase!)
        %i[state country type].each do |k|
          query[k].try(:upcase!)
        end
      end
    end

    def search_results
      @query ||= normalized_query_params

      relation = InstitutionProgram.version(@version[:number])
                                   .joins(:institution)
                                   .search(@query[:name])

      [
        %i[program_type type],
        %i[institutions.institution provider],
        %w[institutions.physical_country country],
        %w[institutions.physical_state state],
        %w[institutions.preferred_provider preferred_provider]
      ].each do |filter_args|
        relation = relation.filter(filter_args[0], @query[filter_args[1]])
      end

      relation
    end

    def facets
      result = {
        type: search_results.filter_count(:program_type),
        state: search_results.filter_count('institutions.state'),
        provider: embed(search_results.filter_count('institutions.institution')),
        country: embed(search_results.filter_count('institutions.country'))
      }

      add_active_search_facets(result)
    end

    def add_active_search_facets(raw_facets)
      add_search_facet(raw_facets, :type)
      add_search_facet(raw_facets, :state)
      add_country_search_facet(raw_facets)
      raw_facets
    end
  end
end
