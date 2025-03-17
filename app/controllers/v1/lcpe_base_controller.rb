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
      response.headers.delete('Cache-Control')
      response.headers.delete('Pragma')
      response.set_header('Expires', 1.week.since.to_s)
      response.set_header('ETag', "W/'#{preload_version}'")
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
