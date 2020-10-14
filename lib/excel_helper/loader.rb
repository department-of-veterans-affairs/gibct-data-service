# frozen_string_literal: true

module ExcelHelper
  module Loader
    include Common::Loader

    def load_from_excel(results, options = {})
      klass.transaction do
        delete_all
        load_records(results, options)
      end
    end
  end
end
