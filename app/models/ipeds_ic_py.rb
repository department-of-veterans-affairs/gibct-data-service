class IpedsIcPy < ActiveRecord::Base
  validates :cross, presence: true
  validates :chg1py3, numericality: { only_integer: true, message: "%{value} is not a fixnum"}, allow_blank: true
  validates :books, numericality: { only_integer: true, message: "%{value} is not a fixnum"}, allow_blank: true

  before_save :set_derived_fields


  USE_COLUMNS = [:tuition_in_state, :tuition_out_of_state, :books]

  #############################################################################
  ## cross=
  ## Strips whitespace and sets value to downcase, and pads ipeds with 0s
  #############################################################################
  def cross=(value)
    value = value.try(:strip).try(:downcase)
    value = nil if value.blank? || value == 'none' 

    write_attribute(:cross, DS::IpedsId.pad(value))
  end

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
