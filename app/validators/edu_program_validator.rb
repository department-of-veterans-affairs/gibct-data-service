# frozen_string_literal: true

class EduProgramValidator < ActiveModel::Validator
  def validate(record)
    if EduProgram.where(['vet_tec_program = ? AND facility_code = ? AND id != ?',
                         record.vet_tec_program, record.facility_code, record.id]).any?
      record.errors[:base] <<
        "The Facility Code & VET TEC Program (Program Name) combination is not unique:
#{record.facility_code}, #{record.vet_tec_program}"
    end

    return if Weam.where(['facility_code = ?', record.facility_code]).any?
    record.errors[:base] <<
      "The Facility Code #{record.facility_code} is not contained within the most recently uploaded weams.csv"
  end
end
