# frozen_string_literal: true

module CsvHelper
  module Loader
    CSV_FIRST_LINE = 2

    SMARTER_CSV_OPTIONS = {
      force_utf8: true, remove_zero_values: false, remove_empty_hashes: true,
      remove_empty_values: true, convert_values_to_numeric: false, remove_unmapped_keys: true
    }.freeze

    def load(file, options = {})
      delete_all
      load_records(file, options)
    end

    private

    def load_records(file, options)
      records = []

      records = klass == Institution ? load_csv_with_version(file, records, options) : load_csv(file, records, options)
      results = klass.import records, ignore: true
      validation_errors(records, results.failed_instances, options)
      results
    end

    def load_csv(file, records, options)
      SmarterCSV.process(file, merge_options(options)).each.with_index do |row, i|
        records << klass.new(row)
      end

      records
    end

    def load_csv_with_version(file, records, options)
      version = Version.current_preview.number
      SmarterCSV.process(file, merge_options(options)).each.with_index do |row, i|
        records << klass.new(row.merge(version: version))
      end

      records
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

    # validations are run before insert to prevent bad data from going into table, then
    # run again to get error messages to display to user
    def validation_errors(records, failed_instances, options)
      # Since row indexes start at 0 and spreadsheets on line 1,
      # add 1 for the difference in indexes and 1 for the header row itself.
      row_offset = CSV_FIRST_LINE + (options[:skip_lines] || 0)

      records.each_with_index do |record, index|
        record.errors.add(:row, "Line #{index + row_offset}") unless record.valid?
        failed_instances << record if record.errors.any?
      end
    end
  end
end
