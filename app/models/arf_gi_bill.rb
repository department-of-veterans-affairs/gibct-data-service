# frozen_string_literal: true
class ArfGiBill < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility no.' => { column: :facility_code, converter: FacilityCodeConverter },
    'school name' => { column: :institution, converter: InstitutionConverter },
    'station' => { column: :station, converter: BaseConverter },
    'count of adv pay students' => { column: :count_of_adv_pay_students, converter: BaseConverter },
    'count of reg students' => { column: :count_of_reg_students, converter: BaseConverter },
    'total count of students' => { column: :gibill, converter: CurrencyConverter },
    'total paid' => { column: :station, converter: CurrencyConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :gibill, numericality: true, allow_blank: true
end
