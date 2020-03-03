# frozen_string_literal: true

class YellowRibbonProgram < ApplicationRecord
  belongs_to :institution

  validates :contribution_amount, numericality: true
  validates :degree_level, presence: true
  validates :division_professional_school, presence: true
  validates :facility_code, presence: true
  validates :number_of_students, numericality: true

  # Finds exact-matching facility_code or partial-matching school and city names
  scope :search, lambda { |query|
    return if query.empty?

    clause = []

    clause.push('lower(city) LIKE (:city)') if query['city']

    clause.push('lower(country) LIKE (:country)') if query['country']

    clause.push('lower(contribution_amount) LIKE (:contribution_amount)') if query['contribution_amount']

    clause.push('lower(number_of_students) LIKE (:number_of_students)') if query['number_of_students']

    if query['school_name_in_yr_database']
      clause.push('lower(school_name_in_yr_database) LIKE (:school_name_in_yr_database)')
    end

    clause.push('lower(state) LIKE (:state)') if query['state']

    where(
      sanitize_sql_for_conditions(
        [
          clause.join(' OR '),
          city: "%#{query['city']}%", # (includes)
          country: (query['country']).to_s, # (is equal)
          contribution_amount: "%#{query['contribution_amount']}%", # (greater than, less than, equal to)
          number_of_students: "%#{query['number_of_students']}%", # (greater than, less than, equal to)
          school_name_in_yr_database: "%#{query['school_name_in_yr_database']}%", # (includes)
          state: (query['state']).to_s # (is equal)
        ]
      )
    )
  }

  scope :version, ->(n) { where(version: n) }
end
