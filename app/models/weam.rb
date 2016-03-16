class Weam < ActiveRecord::Base
	validates :facility_code, presence: true, uniqueness: true
	validates :institution, presence: true

	#############################################################################
	## va_highest_degree_offered
	## Gets the highest degree offered by facility_code at the campus level.
	#############################################################################
	def va_highest_degree_offered
		case facility_code[1,1]
		when "0"
			" "
		when "1", "2", "3"
			"4-year"
		when "4"
			"2-year"
		else
			"NCD"
		end
	end
end
