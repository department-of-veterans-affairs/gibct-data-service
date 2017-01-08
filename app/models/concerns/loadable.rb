# frozen_string_literal: true
module Loadable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def load(filename, options = {})
      delete_all

      rows = SmarterCSV.process(filename, merge_options(options))
      return nil if rows.length.zero?

      loadable_class.import rows.map { |row| loadable_class.new(row) }, validate: true, ignore: true
    end

    def loadable_class
      name.constantize
    end

    def merge_options(options)
      key_mapping = {}
      converter_mapping = {}

      loadable_class::MAP.each_pair do |csv_column, map|
        key = map.keys.first

        key_mapping[csv_column.parameterize.underscore.to_sym] = key
        converter_mapping[key] = map[key]
      end

      options.reverse_merge(
        force_utf8: true, remove_zero_values: false, remove_empty_hashes: true,
        key_mapping: key_mapping, value_converters: converter_mapping,
        convert_values_to_numeric: { except: [:facility_code, :cross, :ope, :ipeds, :unitid, :zip] }
      )
    end
  end
end
