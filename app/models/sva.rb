class Sva < ActiveRecord::Base
  include Standardizable
  
  USE_COLUMNS = [:student_veteran_link]

  override_setters :institution, :cross, :student_veteran_link
  before_save :set_derived_fields

  #############################################################################
  ## set_derived_fields=
  ## Computes the values of derived fields just prior to saving. Note that 
  ## any fields here cannot be part of validations.
  #############################################################################
  def set_derived_fields
    self.student_veteran_link = nil if student_veteran_link.try(:downcase) == "http://www.studentveterans.org"

    true
  end
end
