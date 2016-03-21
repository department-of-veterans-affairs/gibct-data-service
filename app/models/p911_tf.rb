class P911Tf < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true
end
