class IpedsIcAy < ActiveRecord::Base
  validates :cross, presence: true

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
  ## vet2=
  ## Sets strings to nil, otherwise saves the number
  #############################################################################
  def tuition_in_state=(value)
    value = nil if !DS::Number.is_i?(value) # Will cause a save error

    write_attribute(:tuition_in_state, value)
  end

  #############################################################################
  ## tuition_out_of_state=
  ## Sets strings to nil, otherwise saves the number
  #############################################################################
  def tuition_out_of_state=(value)
    value = nil if !DS::Number.is_i?(value) # Will cause a save error

    write_attribute(:tuition_out_of_state, value)
  end

  #############################################################################
  ## books=
  ## Sets strings to nil, otherwise saves the number
  #############################################################################
  def books=(value)
    value = nil if !DS::Number.is_i?(value) # Will cause a save error

    write_attribute(:books, value)
  end  
end
