# frozen_string_literal: true

class YellowRibbonProgram < ApplicationRecord
  belongs_to :institution

  delegate :country, to: :institution

  validates :contribution_amount, numericality: true
  validates :degree_level, presence: true
  validates :division_professional_school, presence: true
  validates :facility_code, presence: true
  validates :number_of_students, numericality: true

  # Finds exact-matching facility_code or partial-matching school and city names
  scope :search, lambda { |query|
    return if query.empty?

    clause = []

    # Filter YellowRibbonPrograms.
    clause.push('lower(yellow_ribbon_programs.city) LIKE (:city)') if query['city']
    clause.push('lower(institutions.country) LIKE (:country)') if query['country']
    clause.push('contribution_amount::int >= 99999') if query['contribution_amount'] == 'unlimited'
    clause.push('number_of_students::int >= 99999') if query['number_of_students'] == 'unlimited'
    clause.push('lower(yellow_ribbon_programs.state) LIKE (:state)') if query['state']
    if query['school_name_in_yr_database']
      clause.push('lower(yellow_ribbon_programs.school_name_in_yr_database) LIKE (:school_name_in_yr_database)')
    end

    joins(:institution).where(
      sanitize_sql_for_conditions(
        [
          clause.join(' AND '),
          city: "%#{query['city']}%", # (includes)
          country: (query['country']).to_s, # (is equal)
          school_name_in_yr_database: "%#{query['school_name_in_yr_database']}%", # (includes)
          state: (query['state']).to_s # (is equal)
        ]
      )
    )
  }

  scope :version, ->(n) { where(version: n) }
end
