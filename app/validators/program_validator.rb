# frozen_string_literal: true

class ProgramValidator < ActiveModel::Validator
  def self.non_unique_error_msg(record)
    "The Facility Code & Description (Program Name) combination is not unique:
#{record.facility_code}, #{record.description}"
  end

  def validate(record)
    duplicates_exist = Program.where(['description = ? AND facility_code = ? AND id != ?',
                                      record.description, record.facility_code, record.id]).any?
    record.errors[:base] << ProgramValidator.non_unique_error_msg(record) if duplicates_exist

    ValidatorUtil.facility_code_in_weam?(record)
  end
end
