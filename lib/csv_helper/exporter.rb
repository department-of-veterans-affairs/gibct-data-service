# frozen_string_literal: true

module CsvHelper
  module Exporter
    def export
      generate(csv_headers)
    end

    def export_institutions_by_version(number)
      generate_version(csv_headers, number)
    end

    private

    def defaults
      Rails.application.config.csv_defaults[klass.name] || Rails.application.config.csv_defaults['generic']
    end

    def csv_headers
      csv_headers = {}

      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        key = info[:column]
        csv_headers[key] = csv_column.split(/\s/).map(&:downcase).join(' ')
      end

      csv_headers
    end

    def generate(csv_headers)
      CSV.generate(col_sep: defaults['col_sep']) do |csv|
        csv << csv_headers.values

        klass == write_row(csv, csv_headers)
      end
    end

    def generate_version(csv_headers, number)
      CSV.generate(col_sep: defaults['col_sep']) do |csv|
        csv << csv_headers.values

        klass == write_versioned_row(csv, csv_headers, number)
      end
    end

    def write_row(csv, csv_headers)
      klass.find_each(batch_size: Settings.active_record.batch_size.find_each) do |record|
        csv << csv_headers.keys.map { |k| format(k, record.public_send(k)) }
      end
    end

    def write_versioned_row(csv, csv_headers, number)
      raise(MissingAttributeError, "#{klass.name} is not versioned") unless klass.has_attribute?('version_id')

      klass.joins(:version).where("versions.number = ?", number).find_each(batch_size: Settings.active_record.batch_size.find_each) do |record|
        csv << csv_headers.keys.map { |k| record.public_send(k) == false ? nil : format(k, record.public_send(k)) }
      end
    end

    def format(key, value)
      return "\"#{value}\"" if key == :ope && value.present?

      value
    end
  end
end
