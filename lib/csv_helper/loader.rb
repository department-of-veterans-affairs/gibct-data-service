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
      results = klass.import records, ignore: true, batch_size: Settings.active_record.batch_size
      after_import_validations(records, results.failed_instances, options)
      results
    end

    def load_csv(file, records, options)
      SmarterCSV.process(file, merge_options(options)).each do |row|
        records << klass.new(row)
      end

      records
    end

    def load_csv_with_version(file, records, options)
      version = Version.current_preview
      SmarterCSV.process(file, merge_options(options)).each do |row|
        records << klass.new(row.merge(version: version.number))
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

    # Default validations are run during import, which prevent bad data from being persisted to the database.
    # This method manually runs validations that were declared with a specific validation context (:after_import).
    # The result is warnings are generated for the end user while the data is allowed to persist to the database.
    def after_import_validations(records, failed_instances, options)
      # Since row indexes start at 0 and spreadsheets on line 1,
      # add 1 for the difference in indexes and 1 for the header row itself.
      row_offset = CSV_FIRST_LINE + (options[:skip_lines] || 0)

      records.each_with_index do |record, index|
        unless record.valid?(:after_import)
          record.errors.add(:row, "Line #{index + row_offset}")
          failed_instances << record if record.persisted?
        end
      end
    end
  end
end
