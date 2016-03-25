class Settlement < ActiveRecord::Base
  validates :cross, presence: true
  validates :institution, presence: true
  validates :settlement_description, presence: true
end
