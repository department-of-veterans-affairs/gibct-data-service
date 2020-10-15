# frozen_string_literal: true

module CsvHelper
  module Loader
    include Common::Loader

    # Since row indexes start at 0 and spreadsheets on line 1,
    # add 1 for the difference in indexes and 1 for the header row itself.
    CSV_FIRST_LINE = 2

    SMARTER_CSV_OPTIONS = {
      force_utf8: true, remove_zero_values: false, remove_empty_hashes: true,
      remove_empty_values: true, convert_values_to_numeric: false, remove_unmapped_keys: true
    }.freeze

    def load_from_csv(file, options = {})
      klass.transaction do
        delete_all
        load_csv_file(file, options)
      end
    end

    def load(results, options = {})
      klass.transaction do
        delete_all
        load_records(results, options)
      end
    end

    private

    def load_csv_file(file, options)
      records = []

      records = if [Program, Weam].include?(klass)
                  load_csv_with_row(file, records, options)
                else
                  load_csv(file, records, options)
                end

      load_records(records, options.reverse_merge(first_line: CSV_FIRST_LINE))
    rescue EOFError
      error_msg = "Bad data was found in a row. Please check ALL ROWS for a double quote (\")
without a closing double quote (\"). "
      raise(StandardError, error_msg)
    end

    def load_csv(file, records, options)
      SmarterCSV.process(file, merge_options(options)).each do |row|
        records << klass.new(row)
      end

      records
    end

    def load_csv_with_row(file, records, options)
      SmarterCSV.process(file, merge_options(options)).each_with_index do |row, index|
        records << klass.new(row.merge(csv_row: document_row(index, options)))
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
  end
end
