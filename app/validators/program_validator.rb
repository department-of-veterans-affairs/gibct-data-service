# frozen_string_literal: true

class ProgramValidator
  def self.after_import_batch_validations(failed_instances)
    duplicate_facility_description_results.each do |record|
      record.errors[:base] << non_unique_error_msg(record)
      add_record_to_failed_instances(record, failed_instances)
    end

    missing_facility_in_weam.each do |record|
      record.errors[:base] << SharedMessages.missing_facility_error_msg(record)
      add_record_to_failed_instances(record, failed_instances)
    end
  end

  def self.add_record_to_failed_instances(record, failed_instances)
    record.errors.add(:row, record.csv_row)
    failed_instances << record
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
