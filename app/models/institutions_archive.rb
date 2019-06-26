# frozen_string_literal: true

require_dependency 'institution'

class InstitutionsArchive < Institution::ActiveRecord::Base
  # class methods
  def self.archive(version)
    number = version.number
    old_institutions = []
    Institution.transaction do
      old_institutions = Institution.where('version < ?', number)
                                  .destroy_all
                                  .map(&:attributes)
    end
    InstitutionsArchive.transaction do
      InstitutionsArchive.create(old_institutions)
    end
  end

end
