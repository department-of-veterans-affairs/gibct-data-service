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

  def self.after_import_validations(records, failed_instances, row_offset)
    str = <<-SQL
      SELECT
          UPPER(facility_code) facility_code,
          UPPER(description) description
        FROM programs
        GROUP BY
          UPPER(facility_code),
          UPPER(description)
        HAVING COUNT(*) > 1
    SQL
    
    sql = Program.send(:sanitize_sql, [str])
    duplicate_results = Program.connection.execute(sql)
    binding.pry
    records.each_with_index do |record, _index|
      unless duplicate_results.to_a
                              .include?(facility_code: record.facility_code.upcase,
                                        description: record.description.upcase)
        next
      end

      record.errors[:base] << non_unique_error_msg(record)
      record.errors.add(:row, "Line #{index + row_offset}")
      failed_instances << record if record.persisted?
    end
  end

  def self.non_unique_error_msg(record)
    "The Facility Code & Description (Program Name) combination is not unique:
#{record.facility_code}, #{record.description}"
  end

  validates :facility_code, presence: true
  validates :program_type, inclusion: { in: InstitutionProgram::PROGRAM_TYPES }
  # validates_with ProgramValidator, on: :after_import
end
