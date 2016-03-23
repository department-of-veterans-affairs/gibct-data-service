class VaCrosswalk < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true
  validates :state, inclusion: { in: DS_ENUM::State.get_names }, allow_blank: true
end
