class IpedsHd < ActiveRecord::Base
 include Standardizable

  validates :cross, presence: true

  USE_COLUMNS = [:vet_tuition_policy_url]

  override_setters :cross, :vet_tuition_policy_url
end
