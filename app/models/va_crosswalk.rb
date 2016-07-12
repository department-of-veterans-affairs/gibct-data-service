###############################################################################
## VaCrosswalk
## Contains a mapping of the VA weams facility_codes to the DOE's OPEs and IPEDs
## ids. This table allows us map data together from CSVs produced by the VA or
## DOE. NOTE that this file must be built second to tie data from the weam
## table to all other tables.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class VaCrosswalk < ActiveRecord::Base  
  include Standardizable
  
  validates :facility_code, presence: true, uniqueness: true

  USE_COLUMNS = [:ope, :cross, :ope6]

  override_setters :ope, :cross, :ope6, :institution, :facility_code
end
