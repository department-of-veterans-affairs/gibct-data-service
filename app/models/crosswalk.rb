# frozen_string_literal: true
class Crosswalk < ActiveRecord::Base
  include Savable, Standardizable

  override_setters

  HEADER_MAP = {
    'facility code' => :facility_code,
    'institution name' => :institution,
    'city' => :city,
    'state' => :state,
    'ipeds' => :cross,
    'ope' => :ope,
    'notes' => :notes
  }.freeze

  validates :facility_code, presence: true
  validates :facility_code, uniqueness: true, unless: :skip_uniqueness
  validates :institution, presence: true
end
