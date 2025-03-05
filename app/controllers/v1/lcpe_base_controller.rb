# frozen_string_literal: true

module V1
  class LcpeBaseController < ApiController
    class PreloadVersionStaleError < StandardError; end

    rescue_from PreloadVersionStaleError, with: :version_invalid

    private

    def validate_preload_version
      preload_version = params[:id].split('@').last
      raise PreloadVersionStaleError unless preload_version == fresh_preload.id.to_s
    end

    def preload_dataset
      return if bypass_versioning?

      set_etag(fresh_preload.id.to_s)
      JSON.parse(fresh_preload.body)
    end

    def fresh_preload
      @fresh_preload ||= ::Lcpe::PreloadDataset.fresh(lcpe_type)
    end

    def lcpe_type
      "Lcpe::#{controller_name.singularize.titleize}"
    end

    def set_etag(preload_version)
      no_store_disabled = response.headers['Cache-Control'].remove('no-store, ')
      response.set_header('Cache-Control', no_store_disabled)

      response.set_header('ETag', preload_version)
    end

    # If additional filter params present, bypass versioning
    def bypass_versioning?
      scrubbed_params.present?
    end

    def scrubbed_params
      params.except(:format, :controller, :action, controller_name.singularize.to_sym)
    end

    def version_invalid
      render json: { error: 'Version invalid' }, status: :conflict
    end
  end
end
