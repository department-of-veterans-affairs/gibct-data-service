###############################################################################
## Mou
## The DOD's Memorandum of Understanding data. Any institution included in the
## file whose Status is either probation or title IV non-compliance will 
## will be indicated in this file.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class Mou < ActiveRecord::Base
  include Standardizable
  
  validates :ope, presence: true

  before_save :set_derived_fields

  STATUSES = ["probation - dod", "title iv non-compliant"]
  USE_COLUMNS = [:dodmou]

  override_setters :ope, :ope6, :institution, :status, :dodmou, :dod_status

  #############################################################################
  ## to_dodmou
  ## Converts the status column to boolean, based on a string match.
  #############################################################################
  def to_dodmou
    !STATUSES.include?(status.try(:downcase))
  end

  #############################################################################
  ## to_dod_status
  ## Converts the status column to a boolean based on a string match.
  #############################################################################
  def to_dod_status
    status.try(:downcase) == STATUSES[0]
  end

  #############################################################################
  ## set_derived_fields=
  ## Computes the values of derived fields just prior to saving. Note that 
  ## any fields here cannot be part of validations.
  #############################################################################
  def set_derived_fields
    self.dodmou = to_dodmou
    self.dod_status = to_dod_status
    
    true
  end
end
