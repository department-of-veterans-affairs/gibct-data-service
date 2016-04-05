class VaCrosswalk < ActiveRecord::Base
  USE_COLUMNS = [:ope, :cross, :ope6]
  
  validates :facility_code, presence: true, uniqueness: true
  before_save :set_derived_fields

  def facility_code=(value)
    write_attribute(:facility_code, value.try(:strip).try(:upcase))
  end

  def ope=(value)
    value = value.try(:strip).try(:downcase)
    value = nil if value.blank? || value == 'none' 

    write_attribute(:ope, DS::OpeId.pad(value))
  end

  def cross=(value)
    value = value.try(:strip).try(:downcase)
    value = nil if value.blank? || value == 'none' 

    write_attribute(:cross, DS::IpedsId.pad(value))
  end

  def set_derived_fields
    self.ope6 = DS::OpeId.to_ope6(ope)
  end
end
