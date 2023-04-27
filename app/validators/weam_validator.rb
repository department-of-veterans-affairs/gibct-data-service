# frozen_string_literal: true

class WeamValidator < BaseValidator
  REQUIREMENT_DESCRIPTIONS = ['Facility codes should be unique'].freeze

  def self.after_import_batch_validations(failed_instances)
    duplicate_facility_code.each do |record|
      record.errors.add(:base, non_unique_error_msg(record))
      add_record_to_failed_instances(record, failed_instances)
    end
  end

  def self.duplicate_facility_code
    subquery = Weam.select('UPPER(facility_code) as facility_code')
                   .group('UPPER(facility_code)').having('count(*) > 1')
    Weam.joins("INNER JOIN (#{subquery.to_sql}) dupes on UPPER(weams.facility_code) = dupes.facility_code")
  end

  def self.non_unique_error_msg(record)
    "The Facility Code is not unique: #{record.facility_code}"
  end
end
