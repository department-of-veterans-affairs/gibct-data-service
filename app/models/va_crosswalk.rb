class VaCrosswalk < ActiveRecord::Base  
  include Standardizable
  
  validates :facility_code, presence: true, uniqueness: true

  USE_COLUMNS = [:ope, :cross, :ope6]

  override_setters :ope, :cross, :ope6, :institution, :facility_code
end
