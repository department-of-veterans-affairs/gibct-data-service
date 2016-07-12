###############################################################################
## ArfGibill
## Contains the number of GI Bill students at an institution.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class ArfGibill < ActiveRecord::Base
  include Standardizable

  validates :facility_code, presence: true, uniqueness: { message: "%{value} has already been used" }
  validates :gibill, numericality: true
  
  USE_COLUMNS = [:gibill]

  override_setters :facility_code, :institution, :gibill
end
