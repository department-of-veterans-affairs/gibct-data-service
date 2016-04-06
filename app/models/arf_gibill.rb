class ArfGibill < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: { message: "%{value} has already been used" }
  validates :gibill, numericality: { only_integer: true }
  
  USE_COLUMNS = [:gibill]

  #############################################################################
  ## facility_code=
  ## Strips whitespace and sets value to upcase
  #############################################################################
  def facility_code=(value)
    write_attribute(:facility_code, value.try(:strip).try(:upcase))
  end
end
