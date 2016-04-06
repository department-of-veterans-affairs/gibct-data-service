class P911Yr < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true

  validates :p911_yr_recipients, numericality: { only_integer: true }
  validates :p911_yellow_ribbon, numericality: true

  USE_COLUMNS = [:p911_yr_recipients, :p911_yellow_ribbon]

  #############################################################################
  ## facility_code=
  ## Strips whitespace and sets value to upcase
  #############################################################################
  def facility_code=(value)
    write_attribute(:facility_code, value.try(:strip).try(:upcase))
  end
end
