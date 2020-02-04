# frozen_string_literal: true

class ArfGiBill < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility no.' => { column: :facility_code, converter: FacilityCodeConverter },
    'school name' => { column: :institution, converter: InstitutionConverter },
    'station' => { column: :station, converter: BaseConverter },
    'count of adv pay students' => { column: :count_of_adv_pay_students, converter: NumberConverter },
    'count of reg students' => { column: :count_of_reg_students, converter: NumberConverter },
    'total count of students' => { column: :gibill, converter: NumberConverter },
    'total paid' => { column: :station, converter: NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :gibill, numericality: true, allow_blank: true
  belongs_to(:weam, foreign_key: 'facility_code', primary_key: :facility_code,
                    inverse_of: :arf_gi_bill)
end
