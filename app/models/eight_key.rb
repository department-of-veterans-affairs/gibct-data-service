###############################################################################
## EightKey
## Contains the 8 Keys for Vet Success for an institution.
###############################################################################
class EightKey < ActiveRecord::Base
 include Standardizable

  USE_COLUMNS = []

  override_setters :institution, :cross, :ope, :ope6
end
