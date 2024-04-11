# frozen_string_literal: true

class VaCautionFlag < ImportableRecord
  CSV_CONVERTER_INFO = {
    'id' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'instnm' => { column: :institution_name, converter: Converters::InstitutionConverter },
    'school_system_name' => { column: :school_system_name, converter: Converters::BaseConverter },
    'settlement_title' => { column: :settlement_title, converter: Converters::BaseConverter },
    'settlement_description' => { column: :settlement_description, converter: Converters::BaseConverter },
    'settlement_date' => { column: :settlement_date, converter: Converters::BaseConverter },
    'settlement_link' => { column: :settlement_link, converter: Converters::BaseConverter },
    'school_closing_date' => { column: :school_closing_date, converter: Converters::BaseConverter },
    'sec_702' => { column: :sec_702, converter: Converters::BooleanConverter }
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
