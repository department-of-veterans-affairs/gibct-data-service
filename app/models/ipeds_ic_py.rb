###############################################################################
## IpedsIcPy
## Provieds tuiton and book cost data, but the inormation here is secondary to
## the information in the IpedsIcAy table.
##
## USE_COLUMNS hold those columns that get copied to the DataCsv table during
## the build process.
###############################################################################
class IpedsIcPy < ActiveRecord::Base
  include Standardizable

  validates :cross, presence: true
  validates :chg1py3, numericality: true, allow_blank: true
  validates :books, numericality: true, allow_blank: true

  before_save :set_derived_fields

  USE_COLUMNS = [:tuition_in_state, :tuition_out_of_state, :books].freeze

  override_setters :cross, :chg1py3, :tuition_in_state, :tuition_out_of_state,
                   :books

  #############################################################################
  ## set_derived_fields=
  ## Computes the values of derived fields just prior to saving. Note that
  ## any fields here cannot be part of validations.
  #############################################################################
  def set_derived_fields
    self.tuition_in_state = chg1py3
    self.tuition_out_of_state = chg1py3
  end
end
