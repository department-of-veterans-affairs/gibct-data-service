###############################################################################
## IpedsHd
## The IPEDS Header file contains the DOE IPeds tuituion policy url.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class IpedsHd < ActiveRecord::Base
 include Standardizable

  validates :cross, presence: true

  USE_COLUMNS = [:vet_tuition_policy_url]

  override_setters :cross, :vet_tuition_policy_url
end
