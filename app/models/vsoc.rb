class Vsoc < ActiveRecord::Base
  include Standardizable
  
  USE_COLUMNS = [:vetsuccess_name, :vetsuccess_email]

  validates :facility_code, presence: true, uniqueness: true

  # #############################################################################
  # ## facility_code=
  # ## Strips whitespace and sets value to upcase
  # #############################################################################
  # def facility_code=(value)
  #   write_attribute(:facility_code, value.try(:strip).try(:upcase))
  # end
end
