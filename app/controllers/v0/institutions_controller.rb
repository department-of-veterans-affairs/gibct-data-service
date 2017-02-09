# frozen_string_literal: true
module V0
  class InstitutionsController < ApiController
    before_action :resolve_version

    # GET /v0/institutions/autocomplete?term=harv
    def autocomplete
      @search_term = params[:term].strip.downcase
      @data = Institution.version(@version).autocomplete(@search_term)
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
      downcase_search_query_params!
      @meta = {
        version: @version,
        count: search_results.count
      }
      render json: search_results.order(:institution).page(params[:page]), meta: @meta
    end

    # GET /v0/institutions/20005123
    def show
      resource = Institution.version(@version).find_by(facility_code: params[:id])

      raise Common::Exceptions::RecordNotFound, params[:id] unless resource

      render json: resource, serializer: InstitutionProfileSerializer,
             meta: { version: @version }
    end

    private

    def downcase_search_query_params!
      %i(type_name student_veteran_group
         yellow_ribbon_scholarship principles_of_excellence
         eight_keys_to_veteran_success caution).each do |k|
        params[k].try(:downcase!)
      end
      %i(country state).each do |k|
        params[k].try(:upcase!)
      end
      params[:name].try(:strip!)
    end

    # rubocop:disable AbcSize
    def search_results
      Institution.version(@version)
                 .search(params[:name])
                 .filter(:caution_flag, params[:caution]) # boolean
                 .filter(:institution_type_name, params[:type_name])
                 .filter(:country, params[:country])
                 .filter(:state, params[:state])
                 .filter(:student_veteran, params[:student_veteran_group]) # boolean
                 .filter(:yr, params[:yellow_ribbon_scholarship]) # boolean
                 .filter(:poe, params[:principles_of_excellence]) # boolean
                 .filter(:eight_keys, params[:eight_keys_to_veteran_success]) # boolean
    end
    # rubocop:enable AbcSize

    # Newest production data version assumed when version param is undefined
    def resolve_version
      v = params[:version]
      @version = v.blank? ? Version.default_version_number : v
    end
  end
end
