# frozen_string_literal: true

class InstitutionProgram < ActiveRecord::Base

  # Given a search term representing a partial school name, returns all
  # schools starting with the search term.
  #
  def self.autocomplete(search_term, limit = 6)
    select('id, facility_code as value, institution as label')
      .where('lower(institution) LIKE (?)', "#{search_term}%")
      .limit(limit)
  end

  scope :version, ->(n) { where(version: n) }
end
