# frozen_string_literal: true

class ProgramValidator < BaseValidator
  def self.after_import_batch_validations(validation_warnings)
    duplicate_facility_description_results.each do |record|
      record.errors[:base] << non_unique_error_msg(record)
      add_warning_message(record, validation_warnings)
    end

    missing_facility_in_weam.each do |record|
      record.errors[:base] << missing_facility_error_msg(record)
      add_warning_message(record, validation_warnings)
    end
  end

  def self.add_warning_message(record, validation_warnings)
    record.errors.add(:row, "Line #{record.csv_row}")
    warning = { index: record.csv_row, record: record }
    validation_warnings << warning
  end

  def self.duplicate_facility_description_results
    subquery = Program.select('UPPER(facility_code) as facility_code, UPPER(description) as description')
                      .group('UPPER(facility_code), UPPER(description)').having('count(*) > 1')
    Program.joins("INNER JOIN (#{subquery.to_sql}) dupes on UPPER(programs.facility_code) = dupes.facility_code
AND UPPER(programs.description) = dupes.description")
  end

  def self.missing_facility_in_weam
    Program.joins('LEFT OUTER JOIN weams ON programs.facility_code = weams.facility_code')
           .where(weams: { facility_code: nil })
  end

  def self.non_unique_error_msg(record)
    "The Facility Code & Description (Program Name) combination is not unique:
#{record.facility_code}, #{record.description}"
  end
end
