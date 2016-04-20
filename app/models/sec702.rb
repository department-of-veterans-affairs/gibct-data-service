class Sec702 < ActiveRecord::Base
  include Standardizable
  
  validates :state, presence: true, uniqueness: true
  validates :state, inclusion: { in: DS::State.get_names, message: "%{value} is not a state" }

  USE_COLUMNS = [:sec_702]

  override_setters :state, :sec_702

  # #############################################################################
  # ## state=
  # ## Converts "state strings" to 2-character uppercase state abbreviations
  # #############################################################################
  # def state=(value)
  #   value = DS::State.get_abbr(value.try(:strip))
  #   write_attribute(:state, value.try(:upcase))
  # end

  # #############################################################################
  # ## sec_702=
  # ## Converts truthy/falsy strings to booleans
  # #############################################################################
  # def sec_702=(value)
  #   write_attribute(:sec_702, DS::Truth.truthy?(value))
  # end
end
