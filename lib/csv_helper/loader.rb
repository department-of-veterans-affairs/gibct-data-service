# frozen_string_literal: true
module CsvHelper
  module Loader
    SMARTER_CSV_OPTIONS = {
      force_utf8: true, remove_zero_values: false, remove_empty_hashes: true,
      remove_empty_values: true, convert_values_to_numeric: false
    }.freeze

    def load(file, user, comment = '', options = {})
      delete_all

      name = file.is_a?(String) ? file : filename.original_filename

      upload = Upload.new(csv_type: klass.name, user: user, filename: name, comment: comment)
      records = load_from_csv(file, options)

      results = klass.import records[:valid], validate: false, ignore: true
      results.failed_instances = records[:invalid]

      upload.update(ok: true)
      results
    end

    private

    def load_from_csv(file, options)
      records = { valid: [], invalid: [] }

      # Since row indexes start at 0 and spreadsheets on line 1,
      # add 1 for the difference in indexes and 1 for the header row itself.
      row_offset = 2 + (options[:skip_lines] || 0)

      SmarterCSV.process(file, merge_options(options)).each.with_index do |row, i|
        record = row_to_record(row, i + row_offset)
        record.errors.any? ? records[:invalid] << record : records[:valid] << record
      end

      records
    end

    def row_to_record(row, i)
      record = klass.new(row)
      record.errors.add(:base, "Csv upload error on line #{i}") unless record.valid?

      record
    end

    def merge_options(options)
      key_mapping = {}
      value_converters = {}

      klass::CSV_CONVERTER_INFO.each_pair do |csv_column, info|
        value_converters[info[:column]] = info[:converter]
        key_mapping[csv_column.tr(' ', '_').to_sym] = info[:column]
      end

      options.reverse_merge(key_mapping: key_mapping, value_converters: value_converters)
             .reverse_merge(SMARTER_CSV_OPTIONS)
    end
  end
end
