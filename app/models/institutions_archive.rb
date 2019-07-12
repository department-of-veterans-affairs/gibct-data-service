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
        create_archives(production_version)
        Institution.where('version >= ? and version < ?', previous_version, production_version).delete_all
      end
    rescue ActiveRecord::StatementInvalid => e
      notice = 'There was an error occurring at the database level'
      error_msg = e.original_exception.result.error_message
      Rails.logger.error "#{notice}: #{error_msg}"
    rescue StandardError => e
      notice = 'There was an error of unexpected origin'
      error_msg = e.message
      Rails.logger.error "#{notice}: #{error_msg}"
    end
  end

  def self.create_archives(production_version)
    str = <<-SQL
      INSERT INTO institutions_archives
        SELECT *
          FROM institutions
          WHERE version < ? ;
    SQL

    sql = sanitize_sql_for_conditions([str, production_version])
    ActiveRecord::Base.connection.execute(sql)
  end
end
