###############################################################################
## IpedsIcAy
## IPEDS Institutional Characterstics Academic Year contains tuiton and book 
## cost data.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class IpedsIcAy < ActiveRecord::Base
  include Standardizable 

  validates :cross, presence: true

  validates :tuition_in_state, numericality: true, allow_blank: true
  validates :tuition_out_of_state, numericality: true, allow_blank: true
  validates :books, numericality: true, allow_blank: true

  USE_COLUMNS = [:tuition_in_state, :tuition_out_of_state, :books]

  override_setters :cross, :tuition_in_state, :tuition_out_of_state, :books
end
