###############################################################################
## P911Yr
## Contains Post 911 GI Bill enrollee counts and tuition paid on a school by
## school basis for the Yellow Ribbon enrollees.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class P911Yr < ActiveRecord::Base
  include Standardizable

  validates :facility_code, presence: true, uniqueness: true
  validates :p911_yr_recipients, numericality: true
  validates :p911_yellow_ribbon, numericality: true

  USE_COLUMNS = [:p911_yr_recipients, :p911_yellow_ribbon].freeze

  override_setters :facility_code, :institution, :p911_yr_recipients,
                   :p911_yellow_ribbon
end
