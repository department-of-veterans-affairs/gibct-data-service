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

      records = if klass == Program
                  load_csv_with_row(file, records, options)
                elsif klass == Institution
                  load_csv_with_version(file, records, options)
                else
                  load_csv(file, records, options)
                end

      results = klass.import records, ignore: true, batch_size: Settings.active_record.batch_size.import

      # using index of -1 since these rows failed during save to the table and not during after_import_validations
      failed_instances = results.failed_instances
                                .map { |result| { index: -1, message: result.display_errors_with_row } }
      after_import_validations(records, failed_instances, options)

      results.failed_instances = failed_instances
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

    def load_csv_with_row(file, records, options)
      SmarterCSV.process(file, merge_options(options)).each_with_index do |row, index|
        records << klass.new(row.merge(csv_row: csv_row(index, options)))
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
      # this a call to custom batch validation checks for large import CSVs
      klass.after_import_batch_validations(records, failed_instances, row_offset(options)) if
          defined? klass.after_import_batch_validations
      return if defined? klass.after_import_batch_validations

      records.each_with_index do |record, index|
        next if record.valid?(:after_import)

        csv_row_number = csv_row(index, options)
        record.errors.add(:row, "Line #{csv_row_number}")
        failed_instances << { index: csv_row_number, message: record.display_errors_with_row } if record.persisted?
      end
    end

    def row_offset(options)
      # Since row indexes start at 0 and spreadsheets on line 1,
      # add 1 for the difference in indexes and 1 for the header row itself.
      CSV_FIRST_LINE + (options[:skip_lines] || 0)
    end

    def csv_row(index, options)
      index + row_offset(options)
    end
  end
end
