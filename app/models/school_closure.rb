# frozen_string_literal: true
class SchoolClosure < ActiveRecord::Base
  include CsvHelper

  COLS_USED_IN_INSTITUTION = [:school_closing, :school_closing_on, :school_closing_message].freeze

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution_name, converter: BaseConverter },
    'school closing' => { column: :school_closing, converter: BooleanConverter },
    'school closing date' => { column: :school_closing_date, converter: BaseConverter },
    'school closing message' => { column: :school_closing_message, converter: BaseConverter },
    'notes' => { column: :notes, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validate :school_closure_conditions

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    if school_closing_date
      self.school_closing_on = Date.strptime(school_closing_date, '%m/%d/%y')
    end
  rescue ArgumentError
    nil
  end

  private

  def school_closure_conditions
    if school_closing && school_closing_on.nil?
      errors.add(:school_closing_date, 'must be m/d/yy')
    elsif !school_closing && school_closing_on
      errors.add(:school_closing, 'must be false if date specified')
    end
  end
end
