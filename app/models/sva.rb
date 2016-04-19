class Sva < ActiveRecord::Base
  include Standardizable
  
  USE_COLUMNS = [:student_veteran_link]

  # #############################################################################
  # ## cross=
  # ## Strips whitespace and sets value to downcase, and pads ipeds with 0s
  # #############################################################################
  # def cross=(value)
  #   value = value.try(:strip).try(:downcase)
  #   value = nil if value.blank? || value == 'none' 

  #   write_attribute(:cross, DS::IpedsId.pad(value))
  # end
end
