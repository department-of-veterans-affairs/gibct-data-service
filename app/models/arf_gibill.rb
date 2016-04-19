class ArfGibill < ActiveRecord::Base
  include Standardizable

  validates :facility_code, presence: true, uniqueness: { message: "%{value} has already been used" }
  validates :gibill, numericality: true
  
  USE_COLUMNS = [:gibill]

  # #############################################################################
  # ## facility_code=
  # ## Strips whitespace and sets value to upcase
  # #############################################################################
  # def facility_code=(value)
  #   write_attribute(:facility_code, value.try(:strip).try(:upcase))
  # end

  # #############################################################################
  # ## gibill=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def gibill=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:gibill, value)
  # end
end
