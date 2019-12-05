# frozen_string_literal: true

class ProgramValidator < BaseValidator
  def self.after_import_batch_validations(failed_instances)
    duplicate_facility_description_results.each do |record|
      message = line_number(record['csv_row']) + non_unique_error_msg(record['facility_code'], record['description'])
      warning = { index: record['csv_row'], message: message }
      failed_instances << warning
    end

    missing_facility_in_weam.each do |program|
      message = line_number(program.csv_row) + BaseValidator.missing_facility_error_msg(program)
      warning = { index: program.csv_row, message: message }
      failed_instances << warning
    end
  end

  def self.duplicate_facility_description_results
    subquery = Program.select('UPPER(facility_code) as facility_code, UPPER(description) as description')
                   .group('UPPER(facility_code), UPPER(description)').having('count(*) > 1')
    Program.joins("INNER JOIN (#{subquery.to_sql}) dupes on UPPER(programs.facility_code) = dupes.facility_code
AND UPPER(programs.description) = dupes.description")
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
