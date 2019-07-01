# frozen_string_literal: true

module CsvHelper
  module Exporter
    def export
      csv_column_info = []

      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        csv_column_info.push(
          'column' => info[:column],
          'non_hash' => info[:non_hash] == true,
          'header' => csv_column.split(/\s/).map(&:downcase).join(' ')
        )
      end

      generate(csv_column_info)
    end

    private

    def generate(csv_column_info)
      CSV.generate do |csv|
        csv << csv_column_info.map { |field| field['header'] }
        klass == Institution ? write_institution_row(csv, csv_column_info) : write_row(csv, csv_column_info)
      end
    end

    def write_row(csv, csv_column_info)
      set_class_for_export.find_each do |record|
        csv << csv_column_info.map { |field| format_value(record, field) }
      end
    end

    def write_institution_row(csv, csv_column_info)
      set_class_for_export.find_each do |record|
        csv << csv_column_info.map { |field| format_institution_value(record, field) }
      end
    end

    def set_class_for_export
      return klass unless klass == Institution

      version = Version.current_preview
      version.present? ? Institution.version(version.number) : Institution
    end

    def format_value(record, field)
      value = field['non_hash'] ? record.send(field['column']) : record[field['column']]
      return "\"#{value}\"" if field['column'] == :ope && record[field['column']].present?
      value
    end

    def format_institution_value(record, field)
      value = field['non_hash'].present? ? record.send(field['column']) : record[field['column']]
      return "\"#{value}\"" if field['column'] == :ope && value.present?
      value
    end
  end
end
