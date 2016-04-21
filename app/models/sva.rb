class Sva < ActiveRecord::Base
  include Standardizable
  
  USE_COLUMNS = [:student_veteran_link]

  override_setters :institution, :cross, :student_veteran_link
end
