class P911Tf < ActiveRecord::Base
  include Standardizable
  
  validates :facility_code, presence: true, uniqueness: true
  validates :p911_recipients, numericality: true
  validates :p911_tuition_fees, numericality: true

  USE_COLUMNS = [:p911_recipients, :p911_tuition_fees]

  override_setters :facility_code, :institution, :p911_recipients, 
    :p911_tuition_fees

  # #############################################################################
  # ## facility_code=
  # ## Strips whitespace and sets value to upcase
  # #############################################################################
  # def facility_code=(value)
  #   write_attribute(:facility_code, value.try(:strip).try(:upcase))
  # end

  # #############################################################################
  # ## p911_recipients=
  # ## Strips whitespace and sets strings to nil, otherwise saves the number
  # #############################################################################
  # def p911_recipients=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:p911_recipients, value)
  # end

  # #############################################################################
  # ## p911_tuition_fees=
  # ## Strips whitespace and sets strings to nil, otherwise saves the number
  # #############################################################################
  # def p911_tuition_fees=(value)
  #   value = nil if !DS::Number.is_f?(value) # Will cause a save error

  #   write_attribute(:p911_tuition_fees, value)
  # end
end
