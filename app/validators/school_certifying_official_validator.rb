# frozen_string_literal: true

class SchoolCertifyingOfficialValidator < ActiveModel::Validator
  REQUIREMENT_DESCRIPTIONS = ["Valid priority values: #{SchoolCertifyingOfficial::VALID_PRIORITY_VALUES}"].freeze

  def validate(record)
    unless SchoolCertifyingOfficial::VALID_PRIORITY_VALUES.include?(record.priority.to_s.upcase)
      record.errors[:base] << 'Priority is not a valid value.'
    end
  end
end
