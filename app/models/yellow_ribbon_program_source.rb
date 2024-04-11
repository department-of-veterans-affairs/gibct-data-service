# frozen_string_literal: true

class YellowRibbonProgramSource < ImportableRecord
  CSV_CONVERTER_INFO = {
    'city' => { column: :city },
    'contribution_amount' => { column: :contribution_amount, converter: Converters::NumberConverter },
    'degree_level' => { column: :degree_level, converter: Converters::BaseConverter },
    'division_professional_school' => { column: :division_professional_school, converter: Converters::BaseConverter },
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'number_of_students' => { column: :number_of_students, converter: Converters::NumberConverter },
    'school_name_in_yr_database' => { column: :school_name_in_yr_database },
    'state' => { column: :state },
    'street_address' => { column: :street_address },
    'zip' => { column: :zip },

    # Unused by GIDS but provided in source file
    'amendment_date' => { column: :amendment_date, converter: Converters::DateConverter },
    'campus' => { column: :campus },
    'consolidated_agreement' => { column: :consolidated_agreement, converter: Converters::BooleanConverter },
    'dat_yr_signed_by_yr_official' => { column: :date_yr_signed_by_yr_official, converter: Converters::DateConverter },
    'date_agreement_received' => { column: :date_agreement_received },
    'date_confirmation_sent' => { column: :date_confirmation_sent, converter: Converters::DateConverter },
    'flight_school' => { column: :flight_school, converter: Converters::BooleanConverter },
    'ineligible' => { column: :ineligible, converter: Converters::BooleanConverter },
    'initials_yr_processor' => { column: :initials_yr_processor },
    'missed_deadline' => { column: :missed_deadline, converter: Converters::BooleanConverter },
    'modified' => { column: :modified, converter: Converters::BooleanConverter },
    'new_school' => { column: :new_school, converter: Converters::BooleanConverter },
    'notes' => { column: :notes },
    'open_ended_agreement' => { column: :open_ended_agreement, converter: Converters::BooleanConverter },
    'public_private' => { column: :public_private },
    'school_name_in_weams' => { column: :school_name_in_weams },
    'sco_email_address' => { column: :sco_email_address },
    'sco_name' => { column: :sco_name },
    'sco_telephone_number' => { column: :sco_telephone_number },
    'sfr_email_address' => { column: :sfr_email_address },
    'sfr_name' => { column: :sfr_name },
    'sfr_telephone_number' => { column: :sfr_telephone_number },
    'updated_for_2011_2012' => { column: :updated_for_2011_2012, converter: Converters::BooleanConverter },
    'withdrawn' => { column: :withdrawn, converter: Converters::BooleanConverter },
    'year_of_yr_participation' => { column: :year_of_yr_participation }
  }.freeze

  validates :contribution_amount, numericality: true
  validates :degree_level, presence: true
  validates :division_professional_school, presence: true
  validates :facility_code, presence: true
  validates :number_of_students, numericality: true
end
