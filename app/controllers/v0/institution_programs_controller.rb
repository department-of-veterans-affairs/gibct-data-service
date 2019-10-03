# frozen_string_literal: true

module V0
  class InstitutionProgramsController < ApiController
    # GET /v0/institution_programs/autocomplete?term=harv

    def autocomplete
      @data = []
      if params[:term]
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

      render json: search_results.order('preferred_provider DESC NULLS LAST, institution_name')
                                 .page(params[:page]), meta: @meta
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
           online_only distance_learning vet_tec_provider].each do |k|
          query[k].try(:downcase!)
        end
      end
    end

    def search_results
      @query ||= normalized_query_params
      relation = InstitutionProgram.search(@query[:name], @query[:include_address])
      [
        %i[program_type type],
        %i[country],
        %i[state],
        [:preferred_provider]
      ].each do |filter_args|
        filter_args << filter_args[0] if filter_args.size == 1
        relation = relation.filter(filter_args[0], @query[filter_args[1]])
      end

      relation
    end

    def facets
      result = {
        program_type: search_results.filter_count(:program_type),
        state: search_results.filter_count(:state),
        country: embed(search_results.filter_count(:country))
      }
      add_active_search_facets(result)
    end

    def add_active_search_facets(raw_facets)
      if @query[:state].present?
        key = @query[:state].downcase
        raw_facets[:state][key] = 0 unless raw_facets[:state].key? key
      end
      if @query[:country].present?
        key = @query[:country].upcase
        raw_facets[:country] << { name: key, count: 0 } unless
          raw_facets[:country].any? { |c| c[:name] == key }
      end
      raw_facets
    end

    # Embed search result counts as a list of hashes with "name"/"count"
    # keys so that open-ended strings such as country names do not
    # get interpreted/mutated as JSON keys.
    def embed(group_counts)
      group_counts.each_with_object([]) do |(k, v), array|
        array << { name: k, count: v }
      end
    end
  end
end
