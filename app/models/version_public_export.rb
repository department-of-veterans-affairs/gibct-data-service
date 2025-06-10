# frozen_string_literal: true

class VersionPublicExport < ApplicationRecord
  belongs_to :version

  def self.build(version_id, progress_callback: nil)
    Rails.logger.info "VersionPublicExport: Building data export for version_id #{version_id}"
    version = Version.find(version_id)

    io = StringIO.new
    zip_writer = Zlib::GzipWriter.new(io)

    write_compressed_institution_data(version, zip_writer, progress_callback:)

    zip_writer.close

    record = find_or_initialize_by({ version_id: version.id })
    record.update({ file_type: 'application/x-gzip', data: io.string })
  end

  def self.write_compressed_institution_data(version, writer, progress_callback: nil)
    total_count = Institution.approved_institutions(version).count
    i = 0
    Institution.approved_institutions(version).limit(10).find_each do |institution|
      progress_callback.call("VersionPublicExport: processed #{i}/#{total_count}") if progress_callback && (i % 100).zero?
      begin
        writer << InstitutionProfileSerializer.new(institution).to_json << "\n"
      rescue StandardError
        nil
      end
      i += 1
    end
  end
end
