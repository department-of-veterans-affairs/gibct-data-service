# frozen_string_literal: true

require_dependency 'institution'

class InstitutionsArchive < Institution::ActiveRecord::Base
  # class methods
  def self.archive(version)
    version_number = version.number

    ActiveRecord::Base.transaction do
      conn = ActiveRecord::Base.connection

      str = <<-SQL
        INSERT INTO institutions_archives
          SELECT * 
            FROM institutions 
            WHERE version < ?;
      SQL

      sql = ActiveRecord::Base.sanitize_sql(str, version_number)
      conn.insert(sql)

      str = <<-SQL
        DELETE FROM institutions WHERE version < ?;
      SQL

      sql = ActiveRecord::Base.sanitize_sql(str, version_number)
      conn.execute(sql)
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
