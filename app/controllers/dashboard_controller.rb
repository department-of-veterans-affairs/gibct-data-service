class DashboardController < ApplicationController
	include Alertable
	
	before_action :authenticate_user! 
	 
	def index
  end
end
