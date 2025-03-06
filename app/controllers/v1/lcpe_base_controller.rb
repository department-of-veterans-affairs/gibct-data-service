# frozen_string_literal: true

module V1
  class LcpeBaseController < ApiController
    class PreloadVersionStaleError < StandardError; end

    rescue_from PreloadVersionStaleError, with: :version_invalid

    FILTER_PARAMS = %i[edu_lac_type_nm state lac_nm page per_page].freeze

    private

    def validate_preload_version
      preload_version = params[:id].split('@').last
      raise PreloadVersionStaleError unless preload_version == fresh_preload.id.to_s
    end

    def preload_dataset
      return if bypass_versioning?

      set_headers(fresh_preload.id.to_s)
      JSON.parse(fresh_preload.body)
    end

    def fresh_preload
      @fresh_preload ||= ::Lcpe::PreloadDataset.fresh(lcpe_type)
    end

    def lcpe_type
      "Lcpe::#{controller_name.singularize.titleize}"
    end

    def set_headers(preload_version)
      response.set_header('Cache-Control', 'no-cache, max-age=0, must-revalidate')
      response.set_header('ETag', preload_version)
    end

    # If additional filter params present, bypass versioning
    def bypass_versioning?
      params.keys.map(&:to_sym).intersect?(FILTER_PARAMS)
    end

    def version_invalid
      render json: { error: 'Version invalid' }, status: :conflict
    end
  end
end
