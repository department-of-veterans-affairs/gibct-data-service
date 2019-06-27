# frozen_string_literal: true

require_dependency 'institution'

class InstitutionsArchive < Institution
  self.table_name = 'institutions_archives'

  # class methods
  def self.archive(version)
    version_number = version.number

    conn = ActiveRecord::Base.connection

    begin
      ActiveRecord::Base.transaction do
        create_archives(version_number, conn)
        cleanup_institutions(version_number, conn)
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

    conn.close
  end

  def self.create_archives(version_number, conn)
    str = <<-SQL
      INSERT INTO institutions_archives
        SELECT *
          FROM institutions
          WHERE version < ? ;
    SQL

    sql = InstitutionsArchive.send(:sanitize_sql, [str, version_number])
    conn.execute(sql)
  end

  def self.cleanup_institutions(version_number, conn)
    str = 'DELETE FROM institutions WHERE version < ? ;'

    sql = Institution.send(:sanitize_sql, [str, version_number])
    conn.execute(sql)
  end
end
