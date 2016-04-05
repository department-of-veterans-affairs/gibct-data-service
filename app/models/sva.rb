class Sva < ActiveRecord::Base
  USE_COLUMNS = [:student_veteran_link]

  def cross=(value)
    value = value.try(:strip).try(:downcase)
    value = nil if value.blank? || value == 'none' 

    write_attribute(:cross, DS::IpedsId.pad(value))
  end
end
