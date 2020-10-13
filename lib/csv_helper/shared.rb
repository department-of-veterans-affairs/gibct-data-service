# frozen_string_literal: true

module CsvHelper
  def self.included(base)
    base.extend Shared
    base.extend Loader
    base.extend Exporter
  end

  module Shared
    def klass
      name.constantize
    end
  end
end
