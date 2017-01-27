# frozen_string_literal: true
class Institution < ActiveRecord::Base
  EMPLOYER = 'ojt'
  LOCALE = {
    11 => 'city',
    12 => 'city',
    13 => 'city',
    21 => 'suburban',
    22 => 'suburban',
    23 => 'suburban',
    31 => 'town',
    32 => 'town',
    33 => 'town',
    41 => 'rural',
    42 => 'rural',
    43 => 'rural'
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
  TYPES = [
    'ojt',
    'private',
    'foreign',
    'correspondence',
    'flight',
    'for profit',
    'public'
  ].freeze

  validates :facility_code, uniqueness: true, presence: true
  validates :institution_type_name, inclusion: { in: TYPES }
  validates :institution, presence: true
  validates :country, presence: true

  self.per_page = 10

  def scorecard_link
    return nil unless school? && cross.present?
    [
      "https://collegescorecard.ed.gov/school/?#{cross}",
      institution.downcase.parameterize
    ].join('-')
  end

  def website_link
    return nil if insturl.blank?
    "http://#{insturl}"
  end

  def vet_website_link
    return nil if vet_tuition_policy_url.blank?
    "http://#{vet_tuition_policy_url}"
  end

  def complaints
    prefix = 'complaints_'
    attributes.each_with_object({}) do |(k, v), complaints|
      complaints[k.gsub(prefix, '')] = v if k.starts_with?(prefix)
      complaints
    end
  end

  # Returns a short locale description
  #
  def locale_type
    LOCALE[locale]
  end

  # Returns the highest degree offered.
  #
  def highest_degree
    DEGREES[pred_degree_awarded] || DEGREES[va_highest_degree_offered.try(:downcase)]
  end

  def school?
    institution_type_name != 'ojt'
  end

  # Given a search term representing a partial school name, returns all
  # schools starting with the search term.
  #
  def self.autocomplete(search_term, limit = 6)
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
    raise ArgumentError, 'Field name is required' if field.blank?
    case value
    when 'true', 'yes'
      where(field => true)
    when 'false', 'no'
      where.not(field => true)
    end
  }

  scope :version, ->(version) {}
end
