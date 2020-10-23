# frozen_string_literal: true

module Common
  def self.included(base)
    base.extend Shared
  end

  module Shared
    def klass
      name.constantize
    end

    def self.file_type_defaults(klass, options = {})
      # Pull the default CSV options to be used
      # If default CSV options exist overwrite generic defaults
      generic_options = Rails.application.config.csv_defaults['generic']
      klass_options = Rails.application.config.csv_defaults[klass]
      default_options = if klass_options.present?
                          generic_options.merge(klass_options)
                        else
                          generic_options
                        end

      # Merge with provided options
      default_options.transform_keys(&:to_sym).merge(options)
    end

    # replace all spaces and dashes with underscores
    # then reduce duplicate underscores in a row to a single underscore
    def self.convert_csv_header(header)
      header.gsub(/\s+|-+/, '_').gsub(/_+/, '_')
    end

    def self.display_csv_header(header)
      header.gsub(/_+/, ' ')
    end
  end
end