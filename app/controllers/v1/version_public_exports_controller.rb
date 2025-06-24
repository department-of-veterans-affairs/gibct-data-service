# frozen_string_literal: true

module V1
  class VersionPublicExportsController < ApiController
    def show
      version_id = params[:id] == 'latest' ? Version.current_production&.id : params[:id]
      export = VersionPublicExport.find_by(version_id: version_id)

      raise Common::Exceptions::Internal::RecordNotFound, params[:id] unless export

      send_data(export.data, filename: "public_export_#{export.version.number}.gz", type: export.file_type, disposition: 'attachment')
    end
  end
end
