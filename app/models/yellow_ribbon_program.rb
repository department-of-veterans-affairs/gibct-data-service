# frozen_string_literal: true

class YellowRibbonProgram < ApplicationRecord
  belongs_to :institution

  validates :city, presence: true
  validates :contribution_amount, numericality: true
  validates :degree_level, presence: true
  validates :division_professional_school, presence: true
  validates :facility_code, presence: true
  validates :number_of_students, numericality: true
  validates :school_name_in_yr_database, presence: true
  validates :state, presence: true
  validates :street_address, presence: true
  validates :zip, presence: true

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

  scope :version, ->(n) { where(version: n) }

  scope :filter_count, lambda { |field|
    group(field).where.not(field => nil).order(field).count
  }
end
