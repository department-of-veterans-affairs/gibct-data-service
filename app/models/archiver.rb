# frozen_string_literal: true

module Archiver
  ARCHIVE_TYPES_BY_PARENT_ID = [
    { source: InstitutionProgram, archive: InstitutionProgramsArchive },
    { source: SchoolCertifyingOfficial, archive: SchoolCertifyingOfficialsArchive }
  ].freeze

  ARCHIVE_TYPES_BY_VERSION_ID = [
    { source: Institution, archive: InstitutionsArchive },
    { source: ZipcodeRate, archive: ZipcodeRatesArchive }
  ].freeze

  def self.archive_previous_versions
    production_version = Version.current_production.number
    previous_version = Version.previous_production.number

    begin
      ApplicationRecord.transaction do
        ARCHIVE_TYPES_BY_PARENT_ID.each do |archivable|
          create_archives_by_parent_id(archivable[:source], archivable[:archive], previous_version, production_version)
          delete_by_parent_id(archivable[:source], archivable[:archive], previous_version, production_version)
        end
      end
      ApplicationRecord.transaction do
        ARCHIVE_TYPES_BY_VERSION_ID.each do |archivable|
          create_archives_by_version_id(archivable[:source], archivable[:archive], previous_version, production_version)
          delete_by_version(archivable[:source], archivable[:archive], previous_version, production_version)
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

  def self.create_archives_by_parent_id(source, archive, previous_version, production_version)
    str = <<~SQL
      INSERT INTO #{archive.table_name}
      SELECT s.* FROM #{source.table_name} s
      JOIN institutions i ON s.institution_id = i.id
      JOIN versions v ON i.version_id = v.id
      WHERE v.number >= ? AND v.number < ?;
    SQL
    sql = archive.send(:sanitize_sql_for_conditions, [str, previous_version, production_version])
    ApplicationRecord.connection.execute(sql)
  end

  def self.delete_by_parent_id(source, archive, previous_version, production_version)
    str = <<-SQL
      DELETE FROM #{source.table_name} s
      USING institutions i, versions v
      WHERE
          s.institution_id = i.id
      AND i.version_id = v.id
      AND v.number >= ? AND v.number < ?;
    SQL
    sql = archive.send(:sanitize_sql_for_conditions, [str, previous_version, production_version])
    ApplicationRecord.connection.execute(sql)
  end

  def self.create_archives_by_version_id(source, archive, previous_version, production_version)
    str = <<-SQL
      INSERT INTO #{archive.table_name}
      SELECT s.* FROM #{source.table_name} s
      JOIN versions v ON s.version_id = v.id
      WHERE v.number >= ? AND v.number < ?;
    SQL
    sql = archive.send(:sanitize_sql_for_conditions, [str, previous_version, production_version])
    ApplicationRecord.connection.execute(sql)
  end

  def self.delete_by_version(source, archive, previous_version, production_version)
    str = <<-SQL
      DELETE FROM #{source.table_name} s
      USING versions v
      WHERE s.version_id = v.id
      AND v.number >= ? AND v.number < ?;
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
