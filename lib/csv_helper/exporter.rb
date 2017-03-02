# frozen_string_literal: true
module CsvHelper
  module Exporter
    def export
      csv_headers = {}

      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        key = info[:column]
        csv_headers[key] = csv_column.split(/\s/).map(&:capitalize).join(' ')
      end

      generate(csv_headers)
    end

    private

    def generate(csv_headers)
      CSV.generate do |csv|
        csv << csv_headers.values

        set_class_for_export.find_each do |record|
          csv << csv_headers.keys.map { |k| record[k] }
        end
      end
    end

    def set_class_for_export
      return klass unless klass == Institution

      version = Version.preview_version
      version.present? ? Institution.version(version.number) : Institution
    end
  end
end
