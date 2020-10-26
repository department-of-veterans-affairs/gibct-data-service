# frozen_string_literal: true

class VaCautionFlag < ImportableRecord
  CSV_CONVERTER_INFO = {
    'id' => { column: :facility_code, converter: FacilityCodeConverter },
    'instnm' => { column: :institution_name, converter: InstitutionConverter },
    'school_system_name' => { column: :school_system_name, converter: BaseConverter },
    'settlement_title' => { column: :settlement_title, converter: BaseConverter },
    'settlement_description' => { column: :settlement_description, converter: BaseConverter },
    'settlement_date' => { column: :settlement_date, converter: BaseConverter },
    'settlement_link' => { column: :settlement_link, converter: BaseConverter },
    'school_closing_date' => { column: :school_closing_date, converter: BaseConverter },
    'sec_702' => { column: :sec_702, converter: BooleanConverter }
  }.freeze

  validates :facility_code, presence: true
  validate :validate_date_fields
  validates_with VaCautionFlagValidator, on: :after_import

  private

  def validate_date_fields
    begin
      Date.strptime(settlement_date, '%m/%d/%y') if settlement_date
    rescue ArgumentError
      errors.add(:settlement_date, 'must be mm/dd/yy')
    end
    begin
      Date.strptime(school_closing_date, '%m/%d/%y') if school_closing_date
    rescue ArgumentError
      errors.add(:school_closing_date, 'must be mm/dd/yy')
    end
  end
end
