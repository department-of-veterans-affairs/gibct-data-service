class IpedsIc < ActiveRecord::Base
  include Standardizable
  
  validates :cross, presence: true
  validates :vet2, inclusion: { in: [-2, -1, 0, 1], message: "'%{value}' not allowed" }
  validates :vet3, inclusion: { in: [-2, -1, 0, 1], message: "'%{value}' not allowed" }
  validates :vet4, inclusion: { in: [-2, -1, 0, 1], message: "'%{value}' not allowed" }
  validates :vet5, inclusion: { in: [-2, -1, 0, 1], message: "'%{value}' not allowed" }
  validates :calsys, inclusion: { in: [-2, 1, 2, 3, 4, 5, 6, 7], message: "'%{value}' not allowed" }
  validates :distnced, inclusion: { in: [-2, -1, 1, 2], message: "'%{value}' not allowed" }

  before_save :set_derived_fields

  USE_COLUMNS = [
    :credit_for_mil_training, :vet_poc, :student_vet_grp_ipeds, 
    :soc_member, :calendar, :online_all
  ]

  override_setters :cross, :vet2, :vet3, :vet4, :vet5, :calsys, :distnced, 
    :credit_for_mil_training, :vet_poc, :student_vet_grp_ipeds, 
    :soc_member, :calendar, :online_all

  # #############################################################################
  # ## cross=
  # ## Strips whitespace and sets value to downcase, and pads ipeds with 0s
  # #############################################################################
  # def cross=(value)
  #   value = value.try(:strip).try(:downcase)
  #   value = nil if value.blank? || value == 'none' 

  #   write_attribute(:cross, DS::IpedsId.pad(value))
  # end

  # #############################################################################
  # ## vet2=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def vet2=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:vet2, value)
  # end

  # #############################################################################
  # ## vet3=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def vet3=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:vet3, value)
  # end

  # #############################################################################
  # ## vet4=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def vet4=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:vet4, value)
  # end

  # #############################################################################
  # ## vet5=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def vet5=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:vet5, value)
  # end

  # #############################################################################
  # ## calsys=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def calsys=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:calsys, value)
  # end

  # #############################################################################
  # ## distnced=
  # ## Sets strings to nil, otherwise saves the number
  # #############################################################################
  # def distnced=(value)
  #   value = nil if !DS::Number.is_i?(value) # Will cause a save error

  #   write_attribute(:distnced, value)
  # end

  #############################################################################
  ## to_yes_string
  ## If the value is 1 (yes), 'Yes' is returned, otherwise a nil is returned
  #############################################################################
  def to_yes_string(value)
    DS::Number.is_i?(value) && value.to_i == 1 ? 'Yes' : nil
  end

  #############################################################################
  ## to_true_string
  ## If the value is 1 (yes), 'true' is returned, otherwise a nil is returned
  #############################################################################
  def to_true_string(value)
    DS::Number.is_i?(value) && value.to_i == 1 ? 'true' : nil
  end

  #############################################################################
  ## to_calendar
  ## Converts the calendar to semesters, ... , otherwise a nil is returned
  #############################################################################
  def to_calendar(value)
    case value
    when -2
      nil
    when 1
      'semesters'
    when 2
      'quarters'
    else
       'nontraditional'
    end
  end

  #############################################################################
  ## set_derived_fields=
  ## Computes the values of derived fields just prior to saving. Note that 
  ## any fields here cannot be part of validations.
  #############################################################################
  def set_derived_fields
    self.credit_for_mil_training = to_yes_string(vet2)
    self.vet_poc = to_yes_string(vet3)
    self.student_vet_grp_ipeds = to_yes_string(vet4)
    self.soc_member = to_yes_string(vet5)
    self.calendar = to_calendar(calsys)
    self.online_all = to_true_string(distnced)

    true
  end
end
