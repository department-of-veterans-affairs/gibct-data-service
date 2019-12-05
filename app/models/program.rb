# frozen_string_literal: true

class Program < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution_name, converter: InstitutionConverter },
    'program type' => { column: :program_type, converter: BaseConverter },
    'description' => { column: :description, converter: BaseConverter },
    'full time undergraduate' => { column: :full_time_undergraduate, converter: BaseConverter },
    'graduate' => { column: :graduate, converter: BaseConverter },
    'full time modifier' => { column: :full_time_modifier, converter: BaseConverter },
    'length' => { column: :length, converter: BaseConverter }
  }.freeze

  validate :facility_code_present
  validate :program_type_valid

  def facility_code_present
    return if facility_code.present?

    errors.add(:facility_code, "can't be blank")
    errors.add(:row, csv_row)
  end

  def program_type_valid
    return if InstitutionProgram::PROGRAM_TYPES.include?(program_type)

    errors.add(:program_type, "#{program_type} is not included in the list of valid institution programs: #{InstitutionProgram::PROGRAM_TYPES.join(', ')}")
    errors.add(:row, csv_row)
  end
end
