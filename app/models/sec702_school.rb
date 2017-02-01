###############################################################################
## Sec702School
## Contains sec 702 compliance on a school by school basis.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class Sec702School < ActiveRecord::Base
  include Standardizable

  validates :facility_code, presence: true, uniqueness: true

  USE_COLUMNS = [:sec_702].freeze

  override_setters :facility_code, :sec_702
end
