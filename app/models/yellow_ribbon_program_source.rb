# frozen_string_literal: true

class YellowRibbonProgramSource < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'degree level' => { column: :degree_level, converter: BaseConverter },
    'division professional school' => { column: :division_professional_school, converter: BaseConverter },
    'number of students' => { column: :number_of_students, converter: NumberConverter },
    'contribution amount' => { column: :contribution_amount, converter: NumberConverter },

    # Unused by GIDS but provided in source file
    'school name in yr database' => { column: :school_name_in_yr_database },
    'school name in weams' => { column: :school_name_in_weams },
    'campus' => { column: :campus },
    'street address' => { column: :street_address },
    'city' => { column: :city },
    'state' => { column: :state },
    'zip' => { column: :zip },
    'public private' => { column: :public_private },
    'updated for 2011-2012' => { column: :updated_for_2011_2012, converter: BooleanConverter },
    'missed deadline' => { column: :missed_deadline, converter: BooleanConverter },
    'ineligible' => { column: :ineligible, converter: BooleanConverter },
    'date agreement received' => { column: :date_agreement_received },
    'dat yr signed by yr official' => { column: :date_yr_signed_by_yr_official, converter: DateConverter },
    'amendment date' => { column: :amendment_date, converter: DateConverter },
    'flight school' => { column: :flight_school, converter: BooleanConverter },
    'date confirmation sent' => { column: :date_confirmation_sent, converter: DateConverter },
    'consolidated agreement' => { column: :consolidated_agreement, converter: BooleanConverter },
    'new school' => { column: :new_school, converter: BooleanConverter },
    'open ended agreement' => { column: :open_ended_agreement, converter: BooleanConverter },
    'modified' => { column: :modified, converter: BooleanConverter },
    'withdrawn' => { column: :withdrawn, converter: BooleanConverter },
    'sco name' => { column: :sco_name },
    'sco telephone number' => { column: :sco_telephone_number },
    'sco email address' => { column: :sco_email_address },
    'sfr name' => { column: :sfr_name },
    'sfr telephone number' => { column: :sfr_telephone_number },
    'sfr email address' => { column: :sfr_email_address },
    'initials yr processor' => { column: :initials_yr_processor },
    'year of yr participation' => { column: :year_of_yr_participation },
    'notes' => { column: :notes }
  }.freeze

  validates :facility_code, presence: true
  validates :degree_level, presence: true
  validates :division_professional_school, presence: true
  validates :number_of_students, numericality: true
  validates :contribution_amount, numericality: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns; end
end
