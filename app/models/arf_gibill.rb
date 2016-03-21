class ArfGibill < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true
  validates :total_count_of_students, presence: true
end
