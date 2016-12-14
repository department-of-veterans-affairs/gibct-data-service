# frozen_string_literal: true
class Weam < ActiveRecord::Base
  include Saveable

  HEADER_MAP = {
    'facility code' => :facility_code,
    'institution name' => :institution,
    'institution city' => :city,
    'institution state' => :state,
    'institution zip code' => :zip,
    'institution country' => :country,
    'accredited' => :accredited,
    'current academic year bah rate' => :bah,
    'principles of excellence' => :poe,
    'current academic year yellow ribbon' => :yr,
    'poo status' => :poo_status,
    'applicable law code' => :applicable_law_code,
    'institution of higher learning indicator' => :institution_of_higher_learning_indicator,
    'ojt indicator' => :ojt_indicator,
    'correspondence indicator' => :correspondence_indicator,
    'flight indicator' => :flight_indicator,
    'non-college degree indicator' => :non_college_degree_indicator
  }.freeze

  validates :facility_code, presence: true
  validates :facility_code, uniqueness: true, unless: :skip_uniqueness
  validates :institution, presence: true
  validates :bah, numericality: true, allow_blank: true
end
