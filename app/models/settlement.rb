###############################################################################
## Settlements
## Contains settlement data for schools in non-compliance with VA policy.
###############################################################################
class Settlement < ActiveRecord::Base
  include Standardizable
  
  validates :cross, presence: true
  validates :settlement_description, presence: true

  override_setters :cross, :institution, :settlement_description
end
