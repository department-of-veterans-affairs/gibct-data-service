# frozen_string_literal: true
module Loadable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def merge_options(klass, options)
      key_mapping = {}
      converter_mapping = {}

      klass::MAP.each_pair do |csv_column, map|
        key = map[:column]

        key_mapping[csv_column.parameterize.underscore.to_sym] = key
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

      rows = rows.map do |row|
        row = klass.new(row)
        row.run_callbacks(:validation)
        row
      end

      klass.import rows, validate: true, ignore: true
    end
  end
end
