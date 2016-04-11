class Settlement < ActiveRecord::Base
  validates :cross, presence: true
  validates :settlement_description, presence: true

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
  ## accreditation_status=
  ## Strips whitespace and sets value to downcase
  #############################################################################
  def settlement_description=(value)
    write_attribute(:settlement_description, value.try(:strip).try(:downcase))
  end
end
