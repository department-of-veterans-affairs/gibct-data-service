class Sec702 < ActiveRecord::Base
  validates :state, uniqueness: true
  validates :state, inclusion: { in: DS::State.get_names }
end
