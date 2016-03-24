class Sec702School < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
end
