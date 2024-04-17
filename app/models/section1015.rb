# frozen_string_literal: true

class Section1015 < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'name_of_institution' => { column: :institution, converter: Converters::InstitutionConverter },
    'eff_date_of_withdrawal' => { column: :effective_date, converter: Converters::DateConverter },
    '#_of_active_students_from_saa_list' => { column: :active_students, converter: Converters::NumberConverter },
    'last_student_to_graduate' => { column: :last_graduate, converter: Converters::DateConverter },
    'celo_sent_to_gi_bill_comparison_tool' => { column: :celo, converter: Converters::BaseConverter },
    'weams_withdraw_processed' => { column: :weams_withdrawal_processed, converter: Converters::BaseConverter }
  }.freeze

  validates :facility_code, presence: true
end
