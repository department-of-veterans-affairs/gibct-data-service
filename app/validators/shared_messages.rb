# frozen_string_literal: true

class SharedMessages
  def self.missing_facility_error_msg(record)
    "The Facility Code #{record.facility_code} is not contained within the most recently uploaded weams.csv"
  end
end
