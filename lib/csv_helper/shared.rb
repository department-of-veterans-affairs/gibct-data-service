# frozen_string_literal: true
module CsvHelper
  def self.included(base)
    base.extend Shared
    base.extend Loader
    base.extend Exporter
  end

  def display_errors_with_row
    return '' if errors.messages.empty?

    row = errors[:row].try(:first).to_s
    keys = errors.keys - [:row]

    "Row #{row.blank? ? 'N/A' : row} : " + keys.map do |key|
      errors[key].join(', ')
    end.join(', ')
  end

  module Shared
    def klass
      name.constantize
    end
  end
end
