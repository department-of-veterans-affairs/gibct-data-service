# frozen_string_literal: true

module Lcpe
  module PreloadHelper
    private

    def preload_dataset
      return unless preload_validation_requested?

      preload = Lcpe::PreloadDataset.fresh_by_type(lcpe_type)
      set_etag(preload.id.to_s)
      JSON.parse(preload.body)
    end

    def preload_validation_requested?
      etag = request.headers['If-None-Match']
      etag&.match(/^[0-9]*$/)
    end

    def lcpe_type
      "Lcpe::#{controller_name.singularize.titleize}"
    end

    def set_etag(preload_version)
      response.set_header('ETag', preload_version)
    end
  end
end
