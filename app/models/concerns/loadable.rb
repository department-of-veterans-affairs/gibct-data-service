# frozen_string_literal: true
module Loadable
  extend ActiveSupport::Concern

  included do
    private_class_method :merge_options, :add_csv_line_number_to_error
  end

  def derive_dependent_columns
    true
  end

  class_methods do
    def add_csv_line_number_to_error(line, record, skip_lines)
      skip_lines = 0 if skip_lines.blank?

      record.errors.add(:base, "Error on CSV line number #{line + 1 + skip_lines}")
    end

    def merge_options(klass, options)
      key_mapping = {}
      converter_mapping = {}

      klass::MAP.each_pair do |csv_column, map|
        key = map[:column]

        key_mapping[csv_column.tr(' ', '_').to_sym] = key
        converter_mapping[key] = map[:converter]
      end

      options.reverse_merge(
        force_utf8: true, remove_zero_values: false, remove_empty_hashes: true,
        key_mapping: key_mapping, value_converters: converter_mapping, remove_empty_values: true,
        convert_values_to_numeric: false
      )
    end

    def load(filename, options = {})
      delete_all

      klass = name.constantize
      rows = SmarterCSV.process(filename, merge_options(klass, options))
      invalid_records = []

      rows = rows.map.with_index do |row, i|
        row = klass.new(row)
        row.run_callbacks(:validation)

        unless row.valid?
          add_csv_line_number_to_error(i, row, options[:skip_lines])
          invalid_records << row
        end
        row
      end

      klass.import rows, validate: false, ignore: true, batch_size: 1
    end
  end
end
