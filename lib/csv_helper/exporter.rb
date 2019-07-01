# frozen_string_literal: true

module CsvHelper
  module Exporter
    def export
      csv_headers = {}

      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        key = info[:column]
        csv_headers[key] = csv_column.split(/\s/).map(&:downcase).join(' ')
      end

      generate(csv_headers)
    end

    private

    def generate(csv_headers)
      CSV.generate do |csv|
        csv << csv_headers.values

        klass == Institution ? write_institution_row(csv, csv_headers) : write_row(csv, csv_headers)
      end
    end

    def write_row(csv, csv_headers)
      set_class_for_export.find_each do |record|
        csv << csv_headers.keys.map { |k| format(k, record.public_send(k)) }
      end
    end

    def write_institution_row(csv, csv_headers)
      set_class_for_export.find_each do |record|
        csv << csv_headers.keys.map { |k| record.public_send(k) == false ? nil : format(k, record.public_send(k)) }
      end
    end

    def set_class_for_export
      return klass unless klass == Institution

      version = Version.current_preview
      version.present? ? Institution.version(version.number) : Institution
    end

    def format(key, value)
      return "\"#{value}\"" if key == :ope && value.present?
      value
    end
  end
end
