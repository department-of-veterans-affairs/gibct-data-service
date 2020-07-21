# frozen_string_literal: true

class VaCautionFlag < ApplicationRecord
  include CsvHelper
    CSV_CONVERTER_INFO = {
      'id' => { column: :facility_code, converter: FacilityCodeConverter },
      'instnm' => { column: :institution_name, converter: InstitutionConverter },
      'school_system_name' => { column: :school_system_name, converter: BaseConverter },
      'settlement_title' => { column: :settlement_title, converter: BaseConverter },
      'settlement_description' => { column: :settlement_description, converter: BaseConverter },
      'settlement_date' => { column: :settlement_date, converter: DateConverter },
      'settlement_link' => { column: :settlement_link, converter: BaseConverter },
      'school_closing_date' => { column: :school_closing_date, converter: DateConverter },
      'sec_702' => { column: :sec_702, converter: BaseConverter }
    }.freeze

    validates :facility_code, presence: true
end