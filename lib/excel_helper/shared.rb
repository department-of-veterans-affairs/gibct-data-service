# frozen_string_literal: true

module ExcelHelper
  include Common
  def self.included(base)
    base.extend Common::Shared
    base.extend Loader
    base.extend CsvHelper::Exporter
  end

  EXTENSIONS = ['.xls, .xlsx'].freeze
  MIME_TYPES = %w[
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  ]
end
