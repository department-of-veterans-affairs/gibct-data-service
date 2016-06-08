class P911Yr < ActiveRecord::Base
  include Standardizable 
  
  validates :facility_code, presence: true, uniqueness: true
  validates :p911_yr_recipients, numericality: true
  validates :p911_yellow_ribbon, numericality: true

  USE_COLUMNS = [:p911_yr_recipients, :p911_yellow_ribbon]

  override_setters :facility_code, :institution, :p911_yr_recipients, 
    :p911_yellow_ribbon
end
