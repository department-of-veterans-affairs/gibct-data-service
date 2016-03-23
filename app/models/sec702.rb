class Sec702 < ActiveRecord::Base
  validates :state, uniqueness: true
  validates :state, inclusion: { in: DS_ENUM::State.get_names }
end
