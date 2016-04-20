class Vsoc < ActiveRecord::Base
  include Standardizable

  validates :facility_code, presence: true, uniqueness: true
  
  USE_COLUMNS = [:vetsuccess_name, :vetsuccess_email]

  override_setters :facility_code, :institution, :vetsuccess_name, 
    :vetsuccess_email

  # #############################################################################
  # ## facility_code=
  # ## Strips whitespace and sets value to upcase
  # #############################################################################
  # def facility_code=(value)
  #   write_attribute(:facility_code, value.try(:strip).try(:upcase))
  # end
end
