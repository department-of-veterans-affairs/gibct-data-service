# frozen_string_literal: true

module Archiver
  ARCHIVE_TYPES = [
    # { source: Institution, archive: InstitutionsArchive }
    # { source: InstitutionProgram, archive: InstitutionProgramsArchive },
    # { source: ZipcodeRate, archive: ZipcodeRatesArchive },
    { source: VersionedSchoolCertifyingOfficial, archive: VersionedScoArchive }
  ].freeze

  def self.archive_previous_versions
    production_version = Version.current_production.number
    previous_version = Version.previous_production.number

    begin
      ActiveRecord::Base.transaction do
        ARCHIVE_TYPES.each do |archivable|
          create_archives(archivable[:source], archivable[:archive], previous_version, production_version)
          archivable[:source].where('version >= ? and version < ?', previous_version, production_version).delete_all
        end
      end
    rescue ActiveRecord::StatementInvalid => exception
      notice = 'There was an error occurring at the database level'
      process_exception(notice, exception, production_version, previous_version)
    rescue StandardError => exception
      notice = 'There was an error of unexpected origin'
      process_exception(notice, exception, production_version, previous_version)
    end
  end

  def self.create_archives(source, archive, previous_version, production_version)
    str = <<-SQL
      INSERT INTO #{archive.table_name}
        SELECT *
          FROM #{source.table_name}
          WHERE version >= ? and version < ? ;
    SQL

    sql = archive.send(:sanitize_sql_for_conditions, [str, previous_version, production_version])
    ActiveRecord::Base.connection.execute(sql)
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
