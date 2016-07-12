###############################################################################
## EightKey
## Contains the 8 Keys for Vet Success for an institution.
###############################################################################
class Hcm < ActiveRecord::Base
 include Standardizable 
  
  validates :ope, presence: true
  validates :hcm_type, presence: true
  validates :hcm_reason, presence: true

  override_setters :ope, :ope6, :institution, :hcm_type, :hcm_reason
end
