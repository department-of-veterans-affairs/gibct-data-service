# frozen_string_literal: true

module CsvHelper
  module Exporter
    def export
      csv_headers = {}
      field_only = {}

      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        key = info[:column]
        csv_headers[key] = csv_column.split(/\s/).map(&:downcase).join(' ')
        field_only[key] = info[:field_only]
      end

      generate(csv_headers, field_only)
    end

    private

    def generate(csv_headers, field_only)
      CSV.generate do |csv|
        csv << csv_headers.values

        klass == Institution ? write_institution_row(csv, csv_headers, field_only) : write_row(csv, csv_headers)
      end
    end

    def write_row(csv, csv_headers)
      set_class_for_export.find_each do |record|
        csv << csv_headers.keys.map { |k| format(k, record[k]) }
      end
    end

    def write_institution_row(csv, csv_headers, field_only)
      set_class_for_export.find_each do |record|
        csv << csv_headers.keys.map { |k| format_institution_field(k, record, field_only[k]) }
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

    def format_institution_field(key, record, field_only)
      value = field_only ? record.send(key) : record[key]
      value = value == false ? nil : value

      return "\"#{value}\"" if key == :ope && value.present?
      value
    end
  end
end
