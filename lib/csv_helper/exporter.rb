# frozen_string_literal: true

module CsvHelper
  module Exporter
    def export
      generate(csv_column_info(), nil)
    end

    def export_archive(version)
      generate(csv_column_info(), version)
    end

    def csv_column_info
      csv_column_info = []
      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        csv_column_info.push(
          'column' => info[:column],
          'non_hash' => info[:non_hash] == true,
          'header' => csv_column.split(/\s/).map(&:downcase).join(' ')
        )
      end
      csv_column_info
    end

    private

    def generate(csv_column_info, version)
      CSV.generate do |csv|
        csv << csv_column_info.map { |field| field['header'] }

        if klass == Institution
          write_institution_row(csv, csv_column_info)          
        elsif version.present?
          write_archived_row(csv, csv_column_info, version)          
        else
          write_row(csv, csv_column_info)
        end
      end
    end

    def write_row(csv, csv_column_info)
      set_class_for_export.find_each do |record|
        csv << csv_headers.keys.map { |k| format(k, record.public_send(k)) }
      end
    end

    def write_institution_row(csv, csv_column_info)
      set_class_for_export.find_each do |record|
        csv << csv_headers.keys.map { |k| record.public_send(k) == false ? nil : format(k, record.public_send(k)) }
      end
    end

    def write_archived_row(csv, csv_column_info, version)
      set_class_for_export.where("version = ?", version).find_in_batches do |group|
        group.each { |record| 
          csv << csv_headers.keys.map { |k| record.public_send(k) == false ? nil : format(k, record.public_send(k)) }
        }
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
