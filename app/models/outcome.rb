###############################################################################
## Outcome
## Contains demographic data on vets vs. public rates.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class Outcome < ActiveRecord::Base
  include Standardizable
  
  validates :facility_code, presence: true, uniqueness: true

  validates :retention_rate_veteran_ba, numericality: true, allow_blank: true
  validates :retention_rate_veteran_otb, numericality: true, allow_blank: true
  validates :persistance_rate_veteran_ba, numericality: true, allow_blank: true
  validates :persistance_rate_veteran_otb, numericality: true, allow_blank: true
  validates :graduation_rate_veteran, numericality: true, allow_blank: true
  validates :transfer_out_rate_veteran, numericality: true, allow_blank: true

  USE_COLUMNS = [
    :retention_rate_veteran_ba, :retention_rate_veteran_otb,
    :persistance_rate_veteran_ba, :persistance_rate_veteran_otb,
    :graduation_rate_veteran, :transfer_out_rate_veteran
  ]

  override_setters :facility_code, :institution, 
    :retention_rate_veteran_ba, :retention_rate_veteran_otb,
    :persistance_rate_veteran_ba, :persistance_rate_veteran_otb,
    :graduation_rate_veteran, :transfer_out_rate_veteran
end
