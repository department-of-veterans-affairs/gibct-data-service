# frozen_string_literal: true

module Common
  def self.included(base)
    base.extend Shared
  end

  module Shared
    def klass
      name.constantize
    end

    # replace all spaces and dashes with underscores
    # then reduce duplicate underscores in a row to a single underscore
    def self.convert_csv_header(header)
      header.gsub(/\s+|-+/, '_').gsub(/_+/, '_')
    end

    def self.display_csv_header(header)
      header.gsub(/_+/, ' ')
    end
  end
end
