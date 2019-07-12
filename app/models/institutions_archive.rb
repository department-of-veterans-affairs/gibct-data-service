# frozen_string_literal: true

require_dependency 'institution'

class InstitutionsArchive < Institution
  self.table_name = 'institutions_archives'

  # class methods
  # rubocop:disable Metrics/MethodLength
  def self.archive_previous_versions(_user)
    production_version = Version.current_production.number
    previous_version = Version.previous_production.number

    begin
      ActiveRecord::Base.transaction do
        create_archives(previous_version, production_version)
        Institution.where('version >= ? and version < ?', previous_version, production_version).delete_all
      end
    rescue ActiveRecord::StatementInvalid => exception
      notice = 'There was an error occurring at the database level'
      error_msg = exception.original_exception.result.error_message
      Raven.tags_context(
        user: current_user,
        date_time: Time.current,
        production_version: production_version,
        previous_version: previous_version
      )
      Raven.capture_exception(exception) if ENV['SENTRY_DSN'].present?
      Rails.logger.error "#{notice}: #{error_msg}"
    rescue StandardError => exception
      notice = 'There was an error of unexpected origin'
      error_msg = exception.message
      Raven.tags_context(
        user: current_user,
        date_time: Time.current,
        production_version: production_version,
        previous_version: previous_version
      )
      Raven.capture_exception(exception) if ENV['SENTRY_DSN'].present?
      Rails.logger.error "#{notice}: #{error_msg}"
    end
  end
  # rubocop:enable Metrics/MethodLength

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
end
