class Sva < ActiveRecord::Base
  validates :institution, presence: true
  validates :state, inclusion: { in: DS_ENUM::State.get_names }, allow_blank: true
end
