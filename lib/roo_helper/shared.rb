# frozen_string_literal: true

module RooHelper
  include Common
  def self.included(base)
    base.extend Common::Shared
    base.extend Loader
    base.extend CsvHelper::Exporter
  end

  EXTENSIONS = %w[.txt .csv .xls .xlsx].freeze
  MIME_TYPES = %w[
    text/plain
    text/csv
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  ].freeze
end
