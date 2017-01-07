# frozen_string_literal: true
module Loadable
  extend ActiveSupport::Concern

  included do
  end

  # Can be overriden to populate columns that are computed ...
  def derive_fields; end

  class_methods do
    def loadable_class
      name.constantize
    end

    def csv_load_options
      {
        force_utf8: true,
        remove_zero_values: false,
        convert_values_to_numeric: { except: [:facility_code, :cross, :ope, :ipeds, :unitid, :zip] }
      }
    end

    def load(filename, options = {})
      delete_all

      rows = SmarterCSV.process(filename, merge_options(options)).map do |c|
        instance = loadable_class.new(c)
        instance.derive_fields

        instance
      end

      # Ignore duplicates ...
      loadable_class.import rows, ignore: true
    end

    def merge_options(options)
      key_mapping = {}
      converter_mapping = {}

      loadable_class::MAP.each_pair do |csv_column, map|
        key = map.keys.first

        key_mapping[csv_column.parameterize.underscore.to_sym] = key
        converter_mapping[key] = map[key]
      end

      csv_load_options.merge(key_mapping: key_mapping, value_converters: converter_mapping).merge(options)
    end
  end
end
