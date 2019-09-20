# frozen_string_literal: true

class ProgramValidator < ActiveModel::Validator
  def validate(record)
    if Program.where(['description = ? AND facility_code = ? AND id != ?',
                      record.description, record.facility_code, record.id]).any?
      record.errors[:base] <<
        "The Facility Code & Description (Program Name) combination is not unique:
#{record.facility_code}, #{record.description}"
    end

    return unless Weam.where(['facility_code = ?', record.facility_code]).none?
    record.errors[:base] <<
      "The Facility Code #{record.facility_code} is not contained within the most recently uploaded weams.csv"
  end
end
