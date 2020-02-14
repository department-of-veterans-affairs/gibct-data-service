# frozen_string_literal: true

module Archiver

  ARCHIVE_TYPES = [
    { source: InstitutionProgram, archive: InstitutionProgramsArchive },
    { source: VersionedSchoolCertifyingOfficial, archive: VersionedSchoolCertifyingOfficialsArchive },
    { source: Institution, archive: InstitutionsArchive },
    { source: ZipcodeRate, archive: ZipcodeRatesArchive }
  ].freeze

  def self.archive_previous_versions
    production_version = Version.current_production.number
    previous_version = Version.previous_production.number

    begin
      ApplicationRecord.transaction do
        ARCHIVE_TYPES.each do |archivable|
          create_archives(archivable[:source], archivable[:archive], previous_version, production_version)
          source = if archivable[:source].has_attribute?(:institution_id)
                     archivable[:source].joins(institution: :version)
                   else
                     archivable[:source].joins(:version)
          end
          source.where('number >= ? AND number <?', previous_version, production_version).delete_all
        end
      end
    rescue ActiveRecord::StatementInvalid => e
      notice = 'There was an error occurring at the database level'
      process_exception(notice, e, production_version, previous_version)
    rescue StandardError => e
      notice = 'There was an error of unexpected origin'
      process_exception(notice, e, production_version, previous_version)
    end
  end

  def self.create_archives(source, archive, previous_version, production_version)
    str = <<~SQL
      INSERT INTO #{archive.table_name}
      SELECT s.* FROM #{source.table_name} s
    SQL
    str += source.has_attribute?(:institution_id) ? 'JOIN institutions i ON s.institution_id = i.id JOIN versions v ON i.version_id = v.id' : 'JOIN versions v ON s.version_id = v.id'
    str += ' WHERE v.number >= ? AND v.number < ?;'
    sql = archive.send(:sanitize_sql_for_conditions, [str, previous_version, production_version])
    ApplicationRecord.connection.execute(sql)
  end

  def self.process_exception(notice, exception, production_version, previous_version)
    Raven.extra_context(
      production_version: production_version,
      previous_version: previous_version
    )
    Raven.capture_exception(exception) if ENV['SENTRY_DSN'].present?
    Rails.logger.error "#{notice}: #{exception.message}"
  end
end
