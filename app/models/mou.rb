class Mou < ActiveRecord::Base
  validates :ope, presence: true
  validates :institution, presence: true
end
