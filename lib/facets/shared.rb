# frozen_string_literal: true

module Facets
  # def self.included(base)
  #   base.extend Shared
  #   base.extend SearchFacets
  # end

  # def display_errors_with_row
  #   return '' if errors.messages.empty?

  #   row = errors[:row].try(:first).to_s
  #   keys = errors.keys - [:row]

  #   "Row #{row.presence || 'N/A'} : " + keys.map do |key|
  #     message = key.to_s == 'base' ? '' : "#{key} : "
  #     message + errors[key].join(', ')
  #   end.join(', ')
  # end

  # module Shared
  #   def klass
  #     name.constantize
  #   end
  # end
end
