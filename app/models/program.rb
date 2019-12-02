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

  def self.after_import_batch_validations(records, failed_instances, row_offset)
    duplicate_results = duplicate_facility_description_results
    facility_not_in_weam = missing_facility_in_weam

    records.each_with_index do |record, index|
      duplicate = duplicate_results.to_a
                                   .include?('facility_code' => record.facility_code&.upcase,
                                             'description' => record.description&.upcase)
      missing_facility = facility_not_in_weam.to_a.include?('facility_code' => record.facility_code&.upcase)

      next unless duplicate || missing_facility

      record.errors[:base] << non_unique_error_msg(record) if duplicate
      record.errors[:base] << BaseValidator.missing_facility_error_msg(record) if missing_facility
      record.errors.add(:row, "Line #{index + row_offset}")
      failed_instances << record if record.persisted?
    end
  end

  def self.duplicate_facility_description_results
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
    Program.connection.execute(sql)
  end

  def self.missing_facility_in_weam
    str = <<-SQL
      SELECT programs.facility_code
      FROM programs LEFT OUTER JOIN weams ON programs.facility_code = weams.facility_code
      WHERE weams.facility_code IS NULL
    SQL
    sql = Program.send(:sanitize_sql, [str])
    Program.connection.execute(sql)
  end

  def self.non_unique_error_msg(record)
    "The Facility Code & Description (Program Name) combination is not unique:
#{record.facility_code}, #{record.description}"
  end
end
