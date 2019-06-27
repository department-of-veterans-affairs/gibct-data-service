# frozen_string_literal: true

require_dependency 'institution'

class InstitutionsArchive < Institution
  # class methods
  def self.archive(version)
    version_number = version.number

    conn = ActiveRecord::Base.connection

    ActiveRecord::Base.transaction do

      str = <<-SQL
        INSERT INTO institutions_archives
          SELECT * 
            FROM institutions 
            WHERE version < ? ;
      SQL

      sql = InstitutionsArchive.send(:sanitize_sql, [str, version_number])
      conn.execute(sql)

      str = 'DELETE FROM institutions WHERE version < ? ;'

      sql = Institution.send(:sanitize_sql, [str, version_number])
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

    conn.close

  end
end
