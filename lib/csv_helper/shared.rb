# frozen_string_literal: true

module CsvHelper
  include Common
  def self.included(base)
    base.extend Common::Shared
    base.extend Loader
    base.extend Exporter
  end

  EXTENSIONS = ['.txt, .csv'].freeze
  MIME_TYPES = %w[text/plain text/csv].freeze
end
