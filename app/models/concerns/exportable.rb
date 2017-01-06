# frozen_string_literal: true
module Exportable
  extend ActiveSupport::Concern

  included do
    ExportableClass = name.constantize
  end

  class_methods do
    def export
      header_mapping = {}

      ExportableClass::MAP.each_pair do |csv_column, map|
        key = map.keys.first
        header_mapping[key] = csv_column.split(' ').map(&:capitalize).join(' ')
      end

      generate(header_mapping)
    end

    def generate(header_mapping)
      CSV.generate do |csv|
        csv << header_mapping.values

        ExportableClass.find_each do |result|
          csv << header_mapping.keys.map { |k| result[k] }
        end
      end
    end
  end
end
