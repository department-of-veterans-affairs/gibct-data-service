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

    "Row #{row.presence || 'N/A'} : " + keys.map do |key|
      if key.to_s == 'base'
        errors[key].join(', ')
      else
        key.to_s + ' : ' + errors[key].join(', ')
      end
    end.join(', ')
  end

  module Shared
    def klass
      name.constantize
    end
  end
end
