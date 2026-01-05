# frozen_string_literal: true

module Common
  def self.included(base)
    base.extend Shared
  end

  module Shared
    def klass
      name.constantize
    end

    def self.file_type_defaults(klass_name, options = {})
      # Pull the default CSV options to be used
      # If default CSV options exist overwrite generic defaults
      generic_options = Rails.application.config.csv_defaults['generic']
      klass_options = Rails.application.config.csv_defaults[klass_name]
      default_options = if klass_options.present?
                          generic_options.deep_merge(klass_options)
                        else
                          generic_options
                        end

      # Merge with provided options
      default_options.transform_keys(&:to_sym).merge(options)
    end

    # Allows for `col_header`, `col-header`, or `col header` in file to return correct info object
    #
    # replace all spaces and dashes with underscores
    # then reduce duplicate underscores in a row to a single underscore
    # Also strips BOM (Byte Order Mark) characters that may appear at the start of CSV files
    def self.convert_csv_header(header)
      # Remove BOM characters (UTF-8, UTF-16, UTF-32)
      cleaned = header.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      cleaned = cleaned.gsub(/\A\xEF\xBB\xBF/, '') # UTF-8 BOM (raw bytes)
      cleaned = cleaned.gsub(/\A\uFEFF/, '')        # UTF-16/UTF-32 BOM
      cleaned = cleaned.sub(/\Aï»¿/, '')            # UTF-8 BOM misread as ISO-8859-1
      cleaned.gsub(/\s+|-+/, '_').gsub(/_+/, '_')
    end

    def self.display_csv_header(header)
      header.gsub(/_+/, ' ')
    end
  end
end
