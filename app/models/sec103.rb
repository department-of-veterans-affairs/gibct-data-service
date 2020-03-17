# frozen_string_literal: true

class Sec103 < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
      'Facility Name' => {column: :name, converter: BaseConverter},
      'Facility Code' => { column: :facility_code, converter: FacilityCodeConverter },
      'Complies with Section 103 (Y/N)' => { column: :complies_with_sec_103, converter: BooleanConverter },
      'Solely Requires COE (Y/N)' => { column: :solely_requires_coe, converter: BooleanConverter },
      'Requires COE & Additional Criteria (Y/N)' => { column: :requires_coe_and_criteria, converter: BooleanConverter }
  }.freeze

  validates :facility_code, presence: true
end