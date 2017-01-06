# frozen_string_literal: true
module Loadable
  extend ActiveSupport::Concern

  included do
    CSV_LOAD_OPTIONS = {
      force_utf8: true,
      remove_zero_values: false,
      convert_values_to_numeric: { except: [:facility_code, :cross, :ope, :ipeds, :unitid, :zip] }
    }.freeze

    LoadableClass = name.constantize
  end

  class_methods do
    def load(filename, options = {})
      delete_all

      rows = SmarterCSV.process(filename, merge_options(options)).map do |c|
        instance = LoadableClass.new(c)
        instance.derive_fields

        instance
      end

      # Ignore duplicates ...
      LoadableClass.import rows, ignore: true
    end

    def merge_options(options)
      key_mapping = {}
      converter_mapping = {}

      LoadableClass::MAP.each_pair do |csv_column, map|
        key = map.keys.first

        key_mapping[csv_column.parameterize.underscore.to_sym] = key
        converter_mapping[key] = map[key]
      end

      CSV_LOAD_OPTIONS.merge(key_mapping: key_mapping, value_converters: converter_mapping).merge(options)
    end
  end
end
