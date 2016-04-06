class P911Tf < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
  validates :p911_recipients, numericality: { only_integer: true }
  validates :p911_tuition_fees, numericality: true

  USE_COLUMNS = [:p911_recipients, :p911_tuition_fees]

  #############################################################################
  ## facility_code=
  ## Strips whitespace and sets value to upcase
  #############################################################################
  def facility_code=(value)
    write_attribute(:facility_code, value.try(:strip).try(:upcase))
  end
end
