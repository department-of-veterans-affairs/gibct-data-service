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

  validates :facility_code, presence: true
  validates :program_type, inclusion: { in: InstitutionProgram::PROGRAM_TYPES }

  def self.after_import_batch_validations(failed_instances)
    duplicate_facility_description_results.each do |record|
      message = line_number(record['csv_row']) + non_unique_error_msg(record['facility_code'], record['description'])
      warning = { index: record['csv_row'], message: message }
      failed_instances << warning
    end

    missing_facility_in_weam.each do |record|
      program = Program.new(record)
      message = line_number(program.csv_row) + BaseValidator.missing_facility_error_msg(program)
      warning = { index: program.csv_row, message: message }
      failed_instances << warning
    end
  end

  def self.duplicate_facility_description_results
    str = <<-SQL
     SELECT programs.csv_row, programs.facility_code, programs.description
      FROM programs
        INNER JOIN (
        SELECT
          UPPER(facility_code) facility_code,
          UPPER(description) description
        FROM programs
        GROUP BY
          UPPER(facility_code),
          UPPER(description)
        HAVING COUNT(*) > 1
        ) dupes on UPPER(programs.facility_code) = dupes.facility_code
        AND UPPER(programs.description) = dupes.description
    SQL

    sql = Program.send(:sanitize_sql, [str])
    Program.connection.execute(sql)
  end

  def self.missing_facility_in_weam
    Program.joins('LEFT OUTER JOIN weams ON programs.facility_code = weams.facility_code')
        .where(weams: { facility_code: nil})
  end

  def self.line_number(csv_row)
    "Line #{csv_row} : "
  end

  def self.non_unique_error_msg(facility_code, description)
    "The Facility Code & Description (Program Name) combination is not unique: #{facility_code}, #{description}"
  end
end
