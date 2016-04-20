class Hcm < ActiveRecord::Base
 include Standardizable 
  
  validates :ope, presence: true
  validates :hcm_type, presence: true
  validates :hcm_reason, presence: true

  override_setters :ope, :ope6, :institution, :hcm_type, :hcm_reason

  # before_save :set_derived_fields

  # #############################################################################
  # ## ope=
  # ## Strips whitespace and sets value to downcase, and pads ope with 0s
  # #############################################################################
  # def ope=(value)
  #   value = value.try(:strip).try(:downcase)
  #   value = nil if value.blank? || value == 'none' 

  #   write_attribute(:ope, DS::OpeId.pad(value))
  # end

  # #############################################################################
  # ## hcm_type=
  # ## Strips whitespace and sets value to downcase
  # #############################################################################
  # def hcm_type=(value)
  #   write_attribute(:hcm_type, value.try(:strip).try(:downcase))
  # end

  # #############################################################################
  # ## hcm_reason=
  # ## Strips whitespace and sets value to downcase
  # #############################################################################
  # def hcm_reason=(value)
  #   write_attribute(:hcm_reason, value.try(:strip).try(:downcase))
  # end

  # #############################################################################
  # ## set_derived_fields=
  # ## Computes the values of derived fields just prior to saving. Note that 
  # ## any fields here cannot be part of validations.
  # #############################################################################
  # def set_derived_fields
  #   self.ope6 = DS::OpeId.to_ope6(ope)
  # end
end
