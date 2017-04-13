# frozen_string_literal: true
require './app/models/errors/csv_header_error'
module CsvHelper
  module Loader
    CSV_FIRST_LINE = 2

    SMARTER_CSV_OPTIONS = {
      force_utf8: true, remove_zero_values: false, remove_empty_hashes: true,
      remove_empty_values: true, convert_values_to_numeric: false, remove_unmapped_keys: true
    }.freeze

    def load(file, options = {})
      # Tackle all upload killers we can predict before deleting database
      diffed = diffed_headers(file, options[:skip_lines] || 0)
      raise ::CsvHeaderError.new(klass, diffed[:missing], diffed[:extra]) if diffed[:errors]

      delete_all
      load_records(file, options)
    end

    private

    def csv_file_headers(file, skip_lines)
      csv = CSV.open(file, return_headers: true, encoding: 'ISO-8859-1')
      skip_lines.times { csv.readline }

      (csv.readline || []).select(&:present?).map { |header| header.downcase.strip }
    end

    def diffed_headers(file, skip_lines)
      model_headers = klass::CSV_CONVERTER_INFO.keys
      file_headers = csv_file_headers(file, skip_lines)

      response = { missing: model_headers - file_headers, extra: file_headers - model_headers }
      response[:errors] = response[:missing].present? || response[:extra].present?

      response
    end

    def load_records(file, options)
      records = { valid: [], invalid: [] }

      records = klass == Institution ? load_csv_with_version(file, records, options) : load_csv(file, records, options)
      results = klass.import records[:valid], validate: false, ignore: true
      results.failed_instances = records[:invalid]

      results
    end

    def load_csv(file, records, options)
      # Since row indexes start at 0 and spreadsheets on line 1,
      # add 1 for the difference in indexes and 1 for the header row itself.
      row_offset = CSV_FIRST_LINE + (options[:skip_lines] || 0)
      SmarterCSV.process(file, merge_options(options)).each.with_index do |row, i|
        record = row_to_record(row, i + row_offset)
        save_record_to_records(records, record)
      end

      records
    end

    def load_csv_with_version(file, records, options)
      version = Version.current_preview
      row_offset = CSV_FIRST_LINE + (options[:skip_lines] || 0)

      SmarterCSV.process(file, merge_options(options)).each.with_index do |row, i|
        record = row_to_record(row.merge(version: version.number), i + row_offset)
        save_record_to_records(records, record)
      end

      records
    end

    def save_record_to_records(records, record)
      record.errors.any? ? records[:invalid] << record : records[:valid] << record
    end

    def row_to_record(row, i)
      record = klass.new(row)
      record.errors.add(:base, "Line #{i}") unless record.valid?

      record
    end

    def merge_options(options)
      key_mapping = {}
      value_converters = {}

      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        value_converters[info[:column]] = info[:converter]
        key_mapping[csv_column.tr(' -', '_').to_sym] = info[:column]
      end

      options.reverse_merge(key_mapping: key_mapping, value_converters: value_converters)
             .reverse_merge(SMARTER_CSV_OPTIONS)
    end
  end
end
