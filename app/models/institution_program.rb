# frozen_string_literal: true

class InstitutionProgram < ApplicationRecord
  PROGRAM_TYPES = %w[
    IHL
    NCD
    OJT
    FLGT
    CORR
  ].freeze

  belongs_to :institution
  delegate :dod_bah, to: :institution
  delegate :preferred_provider, to: :institution
  delegate :facility_code, to: :institution

  self.per_page = 10

  def institution_name
    institution.institution
  end

  def city
    institution.physical_city
  end

  def state
    institution.physical_state
  end

  def country
    institution.physical_country
  end

  def va_bah
    institution.bah
  end

  delegate :school_closing, to: :institution

  delegate :school_closing_on, to: :institution

  delegate :caution_flags, to: :institution

  # Finds exact-matching facility_code or partial-matching school and city names
  #
  scope :search, lambda { |search_term, fuzzy_search = false|
    return if search_term.blank?

    clause = [
      'institution_programs.facility_code = (:facility_code)',
      'lower(description) LIKE (:search_term)'
    ]

    if fuzzy_search
      clause << 'SIMILARITY(institution, :search_term) > :name_threshold'
      clause << 'SIMILARITY(physical_city, :search_term) > :city_threshold'
      clause << 'institutions.physical_zip LIKE (:search_term)'
    else
      clause << 'institutions.institution LIKE (:upper_search_term)'
      clause << 'lower(institutions.physical_city) LIKE (:search_term)'
    end

    where(
      sanitize_sql_for_conditions(
        [clause.join(' OR '),
         facility_code: search_term.upcase,
         upper_search_term: "%#{search_term.upcase}%",
         search_term: "%#{search_term}%",
         name_threshold: Settings.search.institution_name_similarity_threshold,
         city_threshold: Settings.search.institution_city_similarity_threshold]
      )
    )
  }

  scope :filter_result, lambda { |field, value|
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
