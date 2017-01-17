# frozen_string_literal: true
module V0
  class InstitutionsController < ApiController
    # GET /v0/institutions/autocomplete?term=harv
    def autocomplete
      @search_term = params[:term]
      render json: { data: Institution.autocomplete(@search_term) },
             adapter: :json
    end

    # GET /v0/institutions?institution_search=duluth&x=y
    def index
      downcase_search_query_params!
      render json: search_results.order(:institution).page(params[:page])
    end

    # GET /v0/institutions/20005123
    def show
      resource = Institution.find_by(facility_code: params[:id])
      raise Common::Exceptions::RecordNotFound, params[:id] unless resource
      render json: resource, serializer: InstitutionProfileSerializer
    end

    private

    def downcase_search_query_params!
      %i(type_name school_type student_veteran_group
         yellow_ribbon_scholarship principles_of_excellence
         eight_keys_to_veteran_success).each do |k|
        params[k].try(:downcase!)
      end
      %i(country state).each do |k|
        params[k].try(:upcase!)
      end
      params[:name].try(:strip!)
    end

    # rubocop:disable AbcSize
    def search_results
      Institution.search(params[:name])
                 .filter(:institution_type_name, params[:type_name])
                 .filter(:institution_type_name, params[:school_type])
                 .filter(:country, params[:country])
                 .filter(:state, params[:state])
                 .filter(:student_veteran, params[:student_veteran_group])
                 .filter(:yr, params[:yellow_ribbon_scholarship])
                 .filter(:poe, params[:principles_of_excellence])
                 .filter(:eight_keys, params[:eight_keys_to_veteran_success])
    end
    # rubocop:enable AbcSize
  end
end
