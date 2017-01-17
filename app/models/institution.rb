# frozen_string_literal: true
class Institution < ActiveRecord::Base
  include Tristateable

  EMPLOYER = 'ojt'
  LOCALE = {
    11 => 'City',
    12 => 'City',
    13 => 'City',
    21 => 'Suburban',
    22 => 'Suburban',
    23 => 'Suburban',
    31 => 'Town',
    32 => 'Town',
    33 => 'Town',
    41 => 'Rural',
    42 => 'Rural',
    43 => 'Rural'
  }.freeze
  DEGREES = {
    0 => nil,
    'ncd' => 'Certificate',
    1 => 'Certificate',
    '2-year' => 2,
    2 => 2,
    3 => 4,
    4 => 4,
    '4-year' => 4
  }.freeze

  validates :facility_code, uniqueness: true, presence: true
  validates :institution_type_name, presence: true
  validates :institution, presence: true
  validates :country, presence: true

  self.per_page = 10

  def credit_for_mil_training
    tristate_boolean(:credit_for_mil_training)
  end

  def vet_poc
    tristate_boolean(:vet_poc)
  end

  def student_vet_grp_ipeds
    tristate_boolean(:student_vet_grp_ipeds)
  end

  def soc_member
    tristate_boolean(:soc_member)
  end

  def online_all
    tristate_boolean(:online_all)
  end

  # returns true if school is a correspondence school
  #
  def correspondence?
    institution_type_name.casecmp('correspondence').zero?
  end

  # returns true if school is a flight school
  #
  def flight?
    institution_type_name.casecmp('flight').zero?
  end

  # returns true if school is ojt.
  #
  def ojt?
    institution_type_name.casecmp('ojt').zero?
  end

  # returns true if school is not ojt.
  #
  def school?
    !institution_type_name.casecmp('ojt').zero?
  end

  # returns true if school is in USA
  #
  def in_usa?
    country.try(:downcase) == 'usa'
  end

  # Gets the locale name correpsonding to the locale
  #
  def locale_name
    LOCALE[locale] || 'Locale Unknown'
  end

  # Given a search term representing a partial school name, returns all
  # schools starting with the search term.
  #
  def self.autocomplete(search_term, limit = 6)
    search_term = search_term.to_s.strip.downcase
    Institution.select('id, facility_code as value, institution as label')
               .where('lower(institution) LIKE (?)', "#{search_term}%")
               .limit(limit)
  end

  # Finds exact-matching facility_code or partial-matching school and city names
  #
  scope :search, lambda { |search_term|
    return if search_term.blank?
    clause = [
      'lower(facility_code) = (?)',
      'lower(institution) LIKE (?)',
      'lower(city) LIKE (?)'
    ].join(' OR ')
    terms = [
      search_term,
      "%#{search_term}%",
      "%#{search_term}%"
    ]
    where([clause] + terms)
  }

  scope :filter, lambda { |field, value|
    return if value.blank?
    case value
    when value == 'true' || value == 'yes'
      where(field => true)
    else
      where.not(field => true)
    end
  }
end
