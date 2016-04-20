class P911Yr < ActiveRecord::Base
  include Standardizable 
  
  validates :facility_code, presence: true, uniqueness: true
  validates :p911_yr_recipients, numericality: true
  validates :p911_yellow_ribbon, numericality: true

  USE_COLUMNS = [:p911_yr_recipients, :p911_yellow_ribbon]

  override_setters :facility_code, :institution, :p911_yr_recipients, 
    :p911_yellow_ribbon

  # #############################################################################
  # ## facility_code=
  # ## Strips whitespace and sets value to upcase
  # #############################################################################
  # def facility_code=(value)
  #   write_attribute(:facility_code, value.try(:strip).try(:upcase))
  # end

  # #############################################################################
  # ## p911_yr_recipients=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def p911_yr_recipients=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:p911_yr_recipients, value)
  # end

  # #############################################################################
  # ## p911_yellow_ribbon=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def p911_yellow_ribbon=(value)
  #   value = nil if !DS::Number.is_f?(value) # Will cause a save error

  #   write_attribute(:p911_yellow_ribbon, value)
  # end
end
