# frozen_string_literal: true

class BaseValidator
  def self.add_record_to_failed_instances(record, failed_instances)
    record.errors.add(:row, record.csv_row)
    failed_instances << record
  end
end
