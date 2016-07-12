###############################################################################
## Vsoc
## Contains the email and name of the Vet's success rep on campus.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class Vsoc < ActiveRecord::Base
  include Standardizable

  validates :facility_code, presence: true, uniqueness: true
  
  USE_COLUMNS = [:vetsuccess_name, :vetsuccess_email]

  override_setters :facility_code, :institution, :vetsuccess_name, 
    :vetsuccess_email
end
