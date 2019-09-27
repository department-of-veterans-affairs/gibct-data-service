# frozen_string_literal: true

class EduProgramValidator < ActiveModel::Validator
  def self.non_unique_error_msg(record)
    "The Facility Code & VET TEC Program (Program Name) combination is not unique:
#{record.facility_code}, #{record.vet_tec_program}"
  end

  def self.missing_facility_code_error_msg(record)
    "The Facility Code #{record.facility_code} is not contained within the most recently uploaded weams.csv"
  end

  def validate(record)
    duplicates_exist = EduProgram.where(['vet_tec_program = ? AND facility_code = ? AND id != ?',
                                         record.vet_tec_program, record.facility_code, record.id]).any?
    record.errors[:base] << EduProgramValidator.non_unique_error_msg(record) if duplicates_exist

    facility_not_in_weam = Weam.where(['facility_code = ?', record.facility_code]).empty?
    record.errors[:base] << EduProgramValidator.missing_facility_code_error_msg(record) if facility_not_in_weam
  end
end
