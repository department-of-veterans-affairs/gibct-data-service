class Sec702 < ActiveRecord::Base
  include Standardizable
  
  validates :state, presence: true, uniqueness: true
  validates :state, inclusion: { in: DS::State.get_names, message: "%{value} is not a state" }

  USE_COLUMNS = [:sec_702]

  override_setters :state, :sec_702
end
