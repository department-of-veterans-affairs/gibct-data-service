# frozen_string_literal: true

class YellowRibbonProgramSource < ImportableRecord
  CSV_CONVERTER_INFO = {
    'city' => { column: :city },
    'contribution_amount' => { column: :contribution_amount, converter: Converters::NumberConverter },
    'degree_level' => { column: :degree_level, converter: Converters::BaseConverter },
    'division_professional_school' => { column: :division_professional_school, converter: Converters::BaseConverter },
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'number_of_students' => { column: :number_of_students, converter: Converters::NumberConverter },
    'state' => { column: :state },

    # Unused by GIDS but provided in source file
    'campus' => { column: :campus },
    'date_agreement_received' => { column: :date_agreement_received },
    'year_of_yr_participation' => { column: :year_of_yr_participation }
  }.freeze

  validates :contribution_amount, numericality: true
  validates :degree_level, presence: true
  validates :division_professional_school, presence: true
  validates :facility_code, presence: true
  validates :number_of_students, numericality: true
end
