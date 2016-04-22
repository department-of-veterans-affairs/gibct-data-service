class Sec702School < ActiveRecord::Base
  include Standardizable 
  
  validates :facility_code, presence: true, uniqueness: true

  USE_COLUMNS = [:sec_702]

  override_setters :facility_code, :sec_702
end
