class ArfGibill < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true
  validates :gibill, presence: true
end
