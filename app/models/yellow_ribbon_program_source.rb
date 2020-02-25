# frozen_string_literal: true

class YellowRibbonProgramSource < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'city' => { column: :city },
    'contribution amount' => { column: :contribution_amount, converter: NumberConverter },
    'degree level' => { column: :degree_level, converter: BaseConverter },
    'division professional school' => { column: :division_professional_school, converter: BaseConverter },
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'number of students' => { column: :number_of_students, converter: NumberConverter },
    'school name in yr database' => { column: :school_name_in_yr_database },
    'state' => { column: :state },
    'street address' => { column: :street_address },
    'zip' => { column: :zip },

    # Unused by GIDS but provided in source file
    'amendment date' => { column: :amendment_date, converter: DateConverter },
    'campus' => { column: :campus },
    'consolidated agreement' => { column: :consolidated_agreement, converter: BooleanConverter },
    'dat yr signed by yr official' => { column: :date_yr_signed_by_yr_official, converter: DateConverter },
    'date agreement received' => { column: :date_agreement_received },
    'date confirmation sent' => { column: :date_confirmation_sent, converter: DateConverter },
    'flight school' => { column: :flight_school, converter: BooleanConverter },
    'ineligible' => { column: :ineligible, converter: BooleanConverter },
    'initials yr processor' => { column: :initials_yr_processor },
    'missed deadline' => { column: :missed_deadline, converter: BooleanConverter },
    'modified' => { column: :modified, converter: BooleanConverter },
    'new school' => { column: :new_school, converter: BooleanConverter },
    'notes' => { column: :notes },
    'open ended agreement' => { column: :open_ended_agreement, converter: BooleanConverter },
    'public private' => { column: :public_private },
    'school name in weams' => { column: :school_name_in_weams },
    'sco email address' => { column: :sco_email_address },
    'sco name' => { column: :sco_name },
    'sco telephone number' => { column: :sco_telephone_number },
    'sfr email address' => { column: :sfr_email_address },
    'sfr name' => { column: :sfr_name },
    'sfr telephone number' => { column: :sfr_telephone_number },
    'updated for 2011-2012' => { column: :updated_for_2011_2012, converter: BooleanConverter },
    'withdrawn' => { column: :withdrawn, converter: BooleanConverter },
    'year of yr participation' => { column: :year_of_yr_participation }
  }.freeze

  validates :contribution_amount, numericality: true
  validates :degree_level, presence: true
  validates :division_professional_school, presence: true
  validates :facility_code, presence: true
  validates :number_of_students, numericality: true

  scope :version, ->(n) { where(version: n) }
end
