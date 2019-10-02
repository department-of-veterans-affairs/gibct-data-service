# frozen_string_literal: true

class InstitutionProgram < ActiveRecord::Base
  # Given a search term representing a partial school name, returns all
  # schools starting with the search term.
  #
  def self.autocomplete(search_term, limit = 6)
    select('facility_code as value, institution_name as label')
      .where('lower(institution_name) LIKE (?)', "#{search_term}%")
      .limit(limit)
  end

  # Finds exact-matching facility_code or partial-matching school and city names
  #
  scope :search, lambda { |search_term, include_address = false|
    return if search_term.blank?
    clause = [
      'facility_code = (:facility_code)',
      'lower(institution_name) LIKE (:search_term)',
      'lower(institution_city) LIKE (:search_term)'
    ]

    if include_address
      3.times do |i|
        clause << "lower(address_#{i + 1}) LIKE (:search_term)"
      end
    end

    where(
      clause.join(' OR '),
      facility_code: search_term.upcase,
      search_term: "%#{search_term}%"
    )
  }

  scope :filter, lambda { |field, value|
    return if value.blank?
    raise ArgumentError, 'Field name is required' if field.blank?

    case value
    when 'true', 'yes'
      where(field => true)
    when 'false', 'no'
      where.not(field => true)
    else
      where(field => value)
    end
  }

  scope :filter_count, lambda { |field|
    group(field).where.not(field => nil).order(field).count
  }

  scope :version, ->(n) { where(version: n) }
end
