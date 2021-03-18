# frozen_string_literal: true

class InstitutionProgram < ApplicationRecord
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

  # Depending on feature flags determines where clause for search
  scope :search, lambda { |query|
    return if query.blank? || query[:name].blank?

    search_term = query[:name]

    clause = [
      'institution_programs.facility_code = (:upper_search_term)',
      'lower(description) LIKE (:lower_contains_term)',
      'institution % :contains_search_term',
      'UPPER(physical_city) = :upper_search_term',
      'institutions.physical_zip = :search_term',
      'country LIKE :upper_contains_term'
    ]

    where(
      sanitize_sql_for_conditions(
        [clause.join(' OR '),
         upper_search_term: search_term.upcase,
         upper_contains_term: "%#{search_term.upcase}%",
         lower_contains_term: "%#{search_term.downcase}%",
         contains_search_term: "%#{search_term}%",
         search_term: search_term.to_s]
      )
    )
  }

  scope :search_order, lambda { |query|
    order_by = ['institutions.preferred_provider DESC NULLS LAST', 'institutions.institution']
    conditions = [order_by.join(',')]

    if query.present?
      search_term = query[:name]

      order_by.unshift('CASE WHEN UPPER(country) LIKE :upper_contains_term THEN 1 ELSE 0 END DESC')

      conditions = [order_by.join(','), upper_contains_term: "%#{search_term.upcase}%"]
    end

    sanitized_order_by = sanitize_sql_for_conditions(conditions)

    order(Arel.sql(sanitized_order_by))
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
