# frozen_string_literal: true

class VaCautionFlag < ApplicationRecord
  include CsvHelper
  CSV_CONVERTER_INFO = {
    'id' => { column: :facility_code, converter: FacilityCodeConverter },
    'instnm' => { column: :institution_name, converter: InstitutionConverter },
    'school system name' => { column: :school_system_name, converter: BaseConverter },
    'settlement title' => { column: :settlement_title, converter: BaseConverter },
    'settlement description' => { column: :settlement_description, converter: BaseConverter },
    'settlement date' => { column: :settlement_date, converter: BaseConverter },
    'settlement link' => { column: :settlement_link, converter: BaseConverter },
    'school closing date' => { column: :school_closing_date, converter: BaseConverter },
    'sec 702' => { column: :sec_702, converter: BooleanConverter }
  }.freeze

  validates :facility_code, presence: true
  validate :validate_date_fields
  validate :validate_settlement_data
  validate :validate_school_closing_sec702

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

  def validate_settlement_data
    if (!settlement_title.nil? || !settlement_description.nil? || !settlement_link.nil? || !settlement_date.nil?) && (settlement_title.nil? || settlement_description.nil?)
      if settlement_link.nil? && settlement_date.nil?
        errors.add(:base, 'Both settlement title and settlement description are required fo the settlement caution flag to be displayed.')
      else
        errors.add(:base, 'The row has settlement data, but does not have a Title and Description.')
      end
    end
  end

  def validate_school_closing_sec702
    if settlement_title.nil? && settlement_description.nil? && settlement_link.nil? && settlement_date.nil? && school_closing_date.nil? && sec_702.nil?
      errors.add(:base, 'Missing all necessary fields')
    end
  end
end
