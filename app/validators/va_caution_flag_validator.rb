# frozen_string_literal: true

class VaCautionFlagValidator < ActiveModel::Validator
  def validate(record)
    if !record.settlement_title.nil? || !record.settlement_description.nil? || !record.settlement_link.nil? || !record.settlement_date.nil?
      if record.settlement_title.nil? && record.settlement_description.nil?
        record.errors[:base] << 'Both record.settlement title and record.settlement description are required fo the record.settlement caution flag to be displayed.'
      elsif record.settlement_title.nil? || record.settlement_description.nil?
        record.errors[:base] << 'The row has record.settlement data, but does not have a Title and Description.'
      end
    end
  end
end
