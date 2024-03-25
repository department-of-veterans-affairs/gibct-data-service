# frozen_string_literal: true

class Outcome < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[
    retention_rate_veteran_ba retention_rate_veteran_otb
    persistance_rate_veteran_ba persistance_rate_veteran_otb
    graduation_rate_veteran transfer_out_rate_veteran
  ].freeze

  CSV_CONVERTER_INFO = {
    'va_facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'va_facility_name' => { column: :institution, converter: Converters::InstitutionConverter },
    'school_level_va' => { column: :school_level_va, converter: Converters::BaseConverter },
    'retention_rate_veteran_ba' => { column: :retention_rate_veteran_ba, converter: Converters::NumberConverter },
    'retention_rate_veteran_otb' => { column: :retention_rate_veteran_otb, converter: Converters::NumberConverter },
    'persistance_rate_veteran_ba' => { column: :persistance_rate_veteran_ba, converter: Converters::NumberConverter },
    'persistance_rate_veteran_otb' => { column: :persistance_rate_veteran_otb, converter: Converters::NumberConverter },
    'graduation_rate_veteran' => { column: :graduation_rate_veteran, converter: Converters::NumberConverter },
    'transfer_out_rate_veteran' => { column: :transfer_out_rate_veteran, converter: Converters::NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :retention_rate_veteran_ba, numericality: true, allow_blank: true
  validates :retention_rate_veteran_otb, numericality: true, allow_blank: true
  validates :persistance_rate_veteran_ba, numericality: true, allow_blank: true
  validates :persistance_rate_veteran_otb, numericality: true, allow_blank: true
  validates :graduation_rate_veteran, numericality: true, allow_blank: true
  validates :transfer_out_rate_veteran, numericality: true, allow_blank: true
end
