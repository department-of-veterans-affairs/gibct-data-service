class P911Tf < ActiveRecord::Base
  include Standardizable
  
  validates :facility_code, presence: true, uniqueness: true
  validates :p911_recipients, numericality: true
  validates :p911_tuition_fees, numericality: true

  USE_COLUMNS = [:p911_recipients, :p911_tuition_fees]

  override_setters :facility_code, :institution, :p911_recipients, 
    :p911_tuition_fees
end
