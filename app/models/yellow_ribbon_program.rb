# frozen_string_literal: true

class YellowRibbonProgram < ApplicationRecord
  belongs_to :institution

  # Finds exact-matching facility_code or partial-matching school and city names
  scope :search, lambda { |search_term|
    return if search_term.blank?

    clause = [
      'lower(school_name_in_yr_database) LIKE (:search_term)'
    ]

    where(
      sanitize_sql_for_conditions(
        [clause.join(' OR '),
         search_term: "%#{search_term}%"]
      )
    )
  }

  scope :version, ->(n) { where(version: n) }
end
