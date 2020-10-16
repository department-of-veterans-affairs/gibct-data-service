# frozen_string_literal: true

module CsvHelper
  include Common
  def self.included(base)
    base.extend Common::Shared
    base.extend Exporter
  end
end
