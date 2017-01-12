# frozen_string_literal: true
module Exportable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def exportable_class
      name.constantize
    end

    def export
      header_mapping = {}

      exportable_class::MAP.each_pair do |csv_column, mapping|
        key = mapping[:column]
        header_mapping[key] = csv_column.split(/\s/).map(&:capitalize).join(' ')
      end

      generate(header_mapping)
    end

    def generate(header_mapping)
      CSV.generate do |csv|
        csv << header_mapping.values

        exportable_class.find_each do |result|
          csv << header_mapping.keys.map { |k| result[k] }
        end
      end
    end
  end
end
