# frozen_string_literal: true

class GeneratePublicExportJob < ApplicationJob
  def perform
    version = Version.current_production
    existing_export = VersionPublicExport.find_by(version: version)

    return if existing_export

    VersionPublicExport.build(version.id)
  end
end
