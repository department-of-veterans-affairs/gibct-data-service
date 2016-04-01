class VaCrosswalk < ActiveRecord::Base
  USE_COLUMNS = [:ope, :cross]
  
  validates :facility_code, presence: true, uniqueness: true
end
