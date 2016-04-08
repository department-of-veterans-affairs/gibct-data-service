class IpedsHd < ActiveRecord::Base
  validates :cross, presence: true

  USE_COLUMNS = [:vet_tuition_policy_url]
end
