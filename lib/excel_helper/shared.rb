# frozen_string_literal: true

module ExcelHelper
  include Common
  def self.included(base)
    base.extend Common::Shared
    base.extend Loader
    base.extend CsvHelper::Exporter
  end

  XLS_EXTENSION = '.xls'
  XLSX_EXTENSION = '.xlsx'
end
