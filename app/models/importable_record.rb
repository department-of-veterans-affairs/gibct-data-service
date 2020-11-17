# frozen_string_literal: true

class ImportableRecord < ApplicationRecord
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
