# frozen_string_literal: true

class ArfGiBill < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_no.' => { column: :facility_code, converter: FacilityCodeConverter },
    'school_name' => { column: :institution, converter: InstitutionConverter },
    'station' => { column: :station, converter: BaseConverter },
    'count_of_adv_pay_students' => { column: :count_of_adv_pay_students, converter: NumberConverter },
    'count_of_reg_students' => { column: :count_of_reg_students, converter: NumberConverter },
    'total_count_of_students' => { column: :gibill, converter: NumberConverter },
    'total_paid' => { column: :station, converter: NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :gibill, numericality: true, allow_blank: true
  belongs_to(:weam, foreign_key: 'facility_code', primary_key: :facility_code,
                    inverse_of: :arf_gi_bill)
end
