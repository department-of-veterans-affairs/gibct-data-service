# frozen_string_literal: true

class ArfGiBill < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_no.' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'school_name' => { column: :institution, converter: Converters::InstitutionConverter },
    'station' => { column: :station, converter: Converters::BaseConverter },
    'count_of_adv_pay_students' => { column: :count_of_adv_pay_students, converter: Converters::NumberConverter },
    'count_of_reg_students' => { column: :count_of_reg_students, converter: Converters::NumberConverter },
    'total_count_of_students' => { column: :gibill, converter: Converters::NumberConverter },
    'total_paid' => { column: :station, converter: Converters::NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :gibill, numericality: true, allow_blank: true
  belongs_to(:weam, foreign_key: 'facility_code', primary_key: :facility_code,
                    inverse_of: :arf_gi_bill)
end
