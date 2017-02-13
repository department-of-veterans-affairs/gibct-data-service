# frozen_string_literal: true
class Outcome < ActiveRecord::Base
  include CsvHelper

  USE_COLUMNS = [
    :retention_rate_veteran_ba, :retention_rate_veteran_otb,
    :persistance_rate_veteran_ba, :persistance_rate_veteran_otb,
    :graduation_rate_veteran, :transfer_out_rate_veteran
  ].freeze

  CSV_CONVERTER_INFO = {
    'va_facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'va_facility_name' => { column: :institution, converter: InstitutionConverter },
    'school_level_va' => { column: :school_level_va, converter: BaseConverter },
    'retention_rate_veteran_ba' => { column: :retention_rate_veteran_ba, converter: BaseConverter },
    'retention_rate_veteran_otb' => { column: :retention_rate_veteran_otb, converter: BaseConverter },
    'persistance_rate_veteran_ba' => { column: :persistance_rate_veteran_ba, converter: BaseConverter },
    'persistance_rate_veteran_otb' => { column: :persistance_rate_veteran_otb, converter: BaseConverter },
    'graduation_rate_veteran' => { column: :graduation_rate_veteran, converter: BaseConverter },
    'transfer_out_rate_veteran' => { column: :transfer_out_rate_veteran, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :retention_rate_veteran_ba, numericality: true, allow_blank: true
  validates :retention_rate_veteran_otb, numericality: true, allow_blank: true
  validates :persistance_rate_veteran_ba, numericality: true, allow_blank: true
  validates :persistance_rate_veteran_otb, numericality: true, allow_blank: true
  validates :graduation_rate_veteran, numericality: true, allow_blank: true
  validates :transfer_out_rate_veteran, numericality: true, allow_blank: true
end
