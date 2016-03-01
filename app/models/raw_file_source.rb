class RawFileSource < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :build_order, presence: true, uniqueness: true
end
