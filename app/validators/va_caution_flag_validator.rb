# frozen_string_literal: true

class VaCautionFlagValidator < ActiveModel::Validator
  def validate(record)
    if !record.settlement_title.nil? || !record.settlement_description.nil? || !record.settlement_link.nil? || !record.settlement_date.nil?
      if record.settlement_title.nil? && record.settlement_description.nil?
        record.errors[:base] << 'The row has settlement data, but does not have a Title and Description.'
      elsif record.settlement_title.nil? || record.settlement_description.nil?
        record.errors[:base] << 'Both settlement title and settlement description are required for the settlement caution flag to be displayed.'
      end
    end
  end
end
