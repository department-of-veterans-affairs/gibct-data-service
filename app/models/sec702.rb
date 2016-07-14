###############################################################################
## Sec702
## Contains sec 702 compliance on a state by state basis. The information 
## contained here is subordinate to the information in the sec 702 school 
## specific table.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class Sec702 < ActiveRecord::Base
  include Standardizable
  
  validates :state, presence: true, uniqueness: true
  validates :state, inclusion: { in: DS::State.get_names, message: "%{value} is not a state" }

  USE_COLUMNS = [:sec_702]

  override_setters :state, :sec_702
end
