# frozen_string_literal: true

module RooHelper
  include Common
  def self.included(base)
    base.extend Common::Shared
    base.extend Loader
    base.extend CsvHelper::Exporter
  end
end
