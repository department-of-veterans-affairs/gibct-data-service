class Hcm < ActiveRecord::Base
  validates :ope, presence: true
  validates :institution, presence: true
  validates :monitor_method, presence: true
  validates :reason, presence: true
end
