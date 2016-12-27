# frozen_string_literal: true
class DataCsv < ActiveRecord::Base
  def self.version_exists?(version)
    return false if version.nil?

    DataCsv.find_by(version: version).present?
  end

  def self.next_version
    (DataCsv.maximum(:version) || 0) + 1
  end
end
