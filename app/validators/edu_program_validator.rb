# frozen_string_literal: true

class EduProgramValidator < ActiveModel::Validator
  def self.non_unique_error_msg(record)
    "The Facility Code & VET TEC Program (Program Name) combination is not unique:
#{record.facility_code}, #{record.vet_tec_program}"
  end

  def validate(record)
    duplicates_exist = EduProgram.where(['vet_tec_program = ? AND facility_code = ? AND id != ?',
                                         record.vet_tec_program, record.facility_code, record.id]).any?
    record.errors[:base] << EduProgramValidator.non_unique_error_msg(record) if duplicates_exist

    ValidatorUtil.facility_code_in_weam?(record)
  end
end
