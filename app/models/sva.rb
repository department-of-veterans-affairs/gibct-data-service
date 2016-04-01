class Sva < ActiveRecord::Base
  validates :institution, presence: true
  validates :state, inclusion: { in: DS::State.get_names }, allow_blank: true
end
