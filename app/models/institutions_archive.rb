# frozen_string_literal: true

require_dependency 'institution'

class InstitutionsArchive < Institution::ActiveRecord::Base
  # class methods
  def self.archive(version)
    number = version.number

    Institution.transaction do
      str = "INSERT INTO institutions_archives SELECT * FROM institutions WHERE version < #{number};"
      Institution.connection.insert(str)
      str = "DELETE FROM institutions WHERE version < #{number};"
      Institution.connection.execute(str)
    end
  end

end
