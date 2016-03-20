class Scorecard < ActiveRecord::Base
  validates :ope, presence: true
  validates :cross, presence: true

  #############################################################################
  ## graduation_rate_all_students
  #############################################################################
  def graduation_rate_all_students
  end
end
