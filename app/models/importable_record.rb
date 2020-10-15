# frozen_string_literal: true

# This should not have to be here but ruby is not loading this in config/initializers/roo_helper.rb
Dir["#{Rails.application.config.root}/lib/roo_helper/**/*.rb"].each { |f| require(f) }

class ImportableRecord < ApplicationRecord
  include CsvHelper
  include RooHelper

  self.abstract_class = true

  def display_errors_with_row
    return '' if errors.messages.empty?

    row = errors[:row].first.to_s
    keys = errors.keys - [:row]

    "Row #{row.presence || 'N/A'} : " + keys.map do |key|
      message = key.to_s == 'base' ? '' : "#{key} : "
      message + errors[key].join(', ')
    end.join(', ')
  end
end
