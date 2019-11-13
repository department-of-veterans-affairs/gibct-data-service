# frozen_string_literal: true

class EduProgramValidator < BaseValidator
  def validate(record)
    duplicates_exist = EduProgram.where(['vet_tec_program = ? AND facility_code = ? AND id != ?',
                                         record.vet_tec_program, record.facility_code, record.id]).any?
    record.errors[:base] << non_unique_error_msg(record) if duplicates_exist
    record.errors[:base] << "The Facility Code is blank:" if record.facility_code.blank?
    record.errors[:base] << "The VET TEC Program (Program Name) is blank:" if record.vet_tec_program.blank?
    facility_code_in_weam?(record)
  end

  private

  def non_unique_error_msg(record)
    "The Facility Code & VET TEC Program (Program Name) combination is not unique:
#{record.facility_code}, #{record.vet_tec_program}"
  end

end
