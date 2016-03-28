class IpedsIc < ActiveRecord::Base
  validates :cross, presence: true
  validates :vet2, presence: true
  validates :vet3, presence: true
  validates :vet4, presence: true
  validates :vet5, presence: true
  validates :calsys, presence: true
  validates :distnced, presence: true
end
