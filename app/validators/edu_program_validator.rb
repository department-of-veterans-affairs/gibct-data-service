# frozen_string_literal: true

class EduProgramValidator < ActiveModel::Validator
  VALIDATION_DESCRIPTIONS = [
      "The Facility Code & VET TEC Program (Program Name) combination should be unique",
      "The Facility Code should be contained within the most recently uploaded weams.csv"
  ].freeze

  def validate(record)
    duplicates_exist = EduProgram.where(['vet_tec_program = ? AND facility_code = ? AND id != ?',
                                         record.vet_tec_program, record.facility_code, record.id]).any?
    record.errors[:base] << non_unique_error_msg(record) if duplicates_exist
    record.errors[:base] << 'The VET TEC Program (Program Name) is blank:' if record.vet_tec_program.blank?
    facility_code_in_weam?(record)
  end

  private

  def non_unique_error_msg(record)
    "The Facility Code & VET TEC Program (Program Name) combination is not unique:
#{record.facility_code}, #{record.vet_tec_program}"
  end

  def facility_code_in_weam?(record)
    facility_not_in_weam = record.facility_code.present? &&
                           Weam.where(['facility_code = ?', record.facility_code]).empty?
    record.errors[:base] << SharedMessages.missing_facility_error_msg(record) if facility_not_in_weam
  end
end
