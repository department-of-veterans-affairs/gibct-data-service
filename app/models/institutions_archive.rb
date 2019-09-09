# frozen_string_literal: true

require_dependency 'institution'

class InstitutionsArchive < Institution
  self.table_name = 'institutions_archives'

  # class methods
  def self.archive_previous_versions
    production_version = Version.current_production.number
    previous_version = Version.previous_production.number

    begin
      ActiveRecord::Base.transaction do
        create_archives(previous_version, production_version)
        Institution.where('version >= ? and version < ?', previous_version, production_version).delete_all
      end
    rescue ActiveRecord::StatementInvalid => exception
      notice = 'There was an error occurring at the database level'
      error_msg = exception.message
      process_exception(notice, error_msg, production_version, previous_version)
    rescue StandardError => exception
      notice = 'There was an error of unexpected origin'
      error_msg = exception.message
      process_exception(notice, error_msg, production_version, previous_version)
    end
  end

  def self.create_archives(previous_version, production_version)
    str = <<-SQL
      INSERT INTO institutions_archives
        SELECT *
          FROM institutions
          WHERE version >= ? and version < ? ;
    SQL

    sql = sanitize_sql_for_conditions([str, previous_version, production_version])
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.process_exception(notice, error_msg, production_version, previous_version)
    Raven.extra_context(
      production_version: production_version,
      previous_version: previous_version
    )
    Raven.capture_exception(exception) if ENV['SENTRY_DSN'].present?
    Rails.logger.error "#{notice}: #{error_msg}"
  end
end
