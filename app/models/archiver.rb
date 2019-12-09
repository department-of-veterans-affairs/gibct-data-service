# frozen_string_literal: true

module Archiver
  ARCHIVE_TYPES = [
    { source: Institution, archive: InstitutionsArchive },
    { source: ZipcodeRate, archive: ZipcodeRatesArchive },
    { source: InstitutionProgram, archive: InstitutionProgramsArchive },
    { source: VersionedSchoolCertifyingOfficial, archive: VersionedSchoolCertifyingOfficialsArchive }
  ].freeze

  ARCHIVE_TYPES_BY_VERSION_ID = [].freeze

  ARCHIVE_TYPES_BY_PARENT_ID = [].freeze

  def self.archive_previous_versions
    production_version = Version.current_production.number
    previous_version = Version.previous_production.number

    begin
      ApplicationRecord.transaction do
        ARCHIVE_TYPES.each do |archivable|
          create_archives(archivable[:source], archivable[:archive], previous_version, production_version)
          archivable[:source].where('version >= ? and version < ?', previous_version, production_version).delete_all
        end
      end
      ApplicationRecord.transaction do
        ARCHIVE_TYPES_BY_VERSION_ID.each do |archivable|
          create_archives_by_version_id(archivable[:source], archivable[:archive], archivable[:versions], previous_version, production_version)
          archivable[:source].where('version >= ? and version < ?', previous_version, production_version).delete_all
        end
      end
      ApplicationRecord.transaction do
        ARCHIVE_TYPES_BY_PARENT_ID.each do |archivable|
          create_archives_by_parent_id(archivable[:source], archivable[:archive], archivable[:versions], archivable[:institutions], previous_version, production_version)
          archivable[:source].where('version >= ? and version < ?', previous_version, production_version).delete_all
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
    str = <<-SQL
      INSERT INTO #{archive.table_name}
        SELECT *
          FROM #{source.table_name}
          WHERE version >= ? and version < ? ;
    SQL
    sql = archive.send(:sanitize_sql_for_conditions, [str, previous_version, production_version])
    ApplicationRecord.connection.execute(sql)
  end

  def self.create_archives_by_version_id(source, archive, versions, previous_version, production_version)
    str = <<-SQL
      INSERT INTO #{archive.table_name}
      SELECT s.* FROM #{source.table_name} s
      JOIN #{versions.table_name} v ON s.version_id = v.id
      WHERE version >= ? AND version < ?;
    SQL
    sql = archive.send(:sanitize_sql_for_conditions, [str, previous_version, production_version])
    ApplicationRecord.connection.execute(sql)
  end

  def self.create_archives_by_parent_id(source, archive, versions, institutions, previous_version, production_version)
    str = <<-SQL
      INSERT INTO #{archive.table_name}
      SELECT s.* FROM #{source.table_name} s
      JOIN #{institutions.table_name} i ON s.institution_id = i.id
      JOIN #{versions.table_name} v ON s.version_id = v.id
      WHERE s.version >= ? AND s.version < ?;
    SQL
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
