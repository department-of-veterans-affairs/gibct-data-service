# frozen_string_literal: true

module V0
  class InstitutionProgramsController < ApiController
    include Facets

    # GET /v0/institution_programs/autocomplete?term=harv
    def autocomplete
      @data = []
      if params[:term].present?
        @search_term = params[:term]&.strip&.downcase
        @data = InstitutionProgram.joins('INNER JOIN versions v ON v.id = institutions.version_id')
                                  .where('v.number = ?', @version[:number])
                                  .autocomplete(@search_term)
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
      render json: search_results.page(params[:page]), meta: @meta
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

      relation = InstitutionProgram.joins(:institution)
                                   .joins('INNER JOIN versions v ON v.id = institutions.version_id')
                                   .where('v.number = ?', @version[:number])
                                   .search(@query[:name])
                                   .order('institutions.preferred_provider DESC NULLS LAST, institutions.institution')

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
        type: count_field(search_results, :program_type),
        state: count_field(search_results, :state),
        provider: embed(count_field(search_results, :institution_name)),
        country: embed(count_field(search_results, :country))
      }

      add_active_search_facets(result)
    end

    def count_field(relation, field)
      field_map = Hash.new(0)
      relation.map do |program|
        value = program.send(field)
        field_map[value] += 1 if value.present?
      end
      field_map
    end

    def add_active_search_facets(raw_facets)
      add_search_facet(raw_facets, :type)
      add_search_facet(raw_facets, :state)
      add_country_search_facet(raw_facets)
      raw_facets
    end
  end
end
