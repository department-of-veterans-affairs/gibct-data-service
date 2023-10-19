# frozen_string_literal: true

class Section1015 < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'name_of_institution' => { column: :institution, converter: InstitutionConverter },
    'eff_date_of_withdrawal' => { column: :effective_date, converter: DateConverter },
    '#_of_active_students_from_saa_list' => { column: :active_students, converter: NumberConverter },
    'last_student_to_graduate' => { column: :last_graduate, converter: DateConverter },
    'celo_sent_to_gi_bill_comparison_tool' => { column: :celo, converter: BaseConverter },
    'weams_withdraw_processed' => { column: :weams_withdrawal_processed, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
end
