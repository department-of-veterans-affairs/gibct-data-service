# frozen_string_literal: true

class CrosswalksController < ApplicationController
  def index
    @issues = CrosswalkIssue.includes(%i[weam crosswalk ipeds_hd]).all.order('weams.institution, weams.facility_code')
  end
end
