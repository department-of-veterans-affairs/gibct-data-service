# frozen_string_literal: true
module V0
  class InstitutionsController < ApiController
    # GET /v0/institutions/autocomplete?term=harv
    def autocomplete
      @data = []
      if params[:term]
        @search_term = params[:term]&.strip&.downcase
        @data = Institution.version(@version[:number]).autocomplete(@search_term)
      end
      @meta = {
        version: @version,
        term: @search_term
      }
      @links = {
        self: autocomplete_v0_institutions_url(term: params[:term])
      }
      render json: { data: @data, links: @links, meta: @meta }, adapter: :json
    end

    # GET /v0/institutions?name=duluth&x=y
    def index
      @meta = {
        version: @version,
        count: search_results.count,
        facets: facets
      }
      render json: search_results.order(:institution).page(params[:page]), meta: @meta
    end

    # GET /v0/institutions/20005123
    def show
      resource = Institution.version(@version[:number]).find_by(facility_code: params[:id])

      raise Common::Exceptions::RecordNotFound, params[:id] unless resource

      render json: resource, serializer: InstitutionProfileSerializer,
             meta: { version: @version }
    end

    private

    def normalized_query_params
      query = params.deep_dup
      query.tap do
        query[:name].try(:strip!)
        query[:name].try(:downcase!)
        %i(state country).each do |k|
          query[k].try(:upcase!)
        end
        %i(type_name student_veteran_group yellow_ribbon_scholarship principles_of_excellence
           eight_keys_to_veteran_success caution).each do |k|
          query[k].try(:downcase!)
        end
      end
    end

    # rubocop:disable AbcSize
    def search_results
      @query ||= normalized_query_params
      Institution.version(@version[:number])
                 .search(@query[:name])
                 .filter(:caution_flag, @query[:caution]) # boolean
                 .filter(:institution_type_name, @query[:type_name])
                 .filter(:country, @query[:country])
                 .filter(:state, @query[:state])
                 .filter(:student_veteran, @query[:student_veteran_group]) # boolean
                 .filter(:yr, @query[:yellow_ribbon_scholarship]) # boolean
                 .filter(:poe, @query[:principles_of_excellence]) # boolean
                 .filter(:eight_keys, @query[:eight_keys_to_veteran_success]) # boolean
    end

    def facets
      institution_types = search_results.filter_count(:institution_type_name)
      {
        type: {
          school: institution_types.except(Institution::EMPLOYER).inject(0) { |count, (_t, n)| count + n },
          employer: institution_types[Institution::EMPLOYER].to_i
        },
        type_name: institution_types,
        state: search_results.filter_count(:state),
        country: search_results.filter_count(:country),
        caution_flag: search_results.filter_count(:caution_flag),
        student_vet_group: search_results.filter_count(:student_veteran),
        yellow_ribbon_scholarship: search_results.filter_count(:yr),
        principles_of_excellence: search_results.filter_count(:poe),
        eight_keys_to_veteran_success: search_results.filter_count(:eight_keys)
      }
    end
    # rubocop:enable AbcSize
  end
end
