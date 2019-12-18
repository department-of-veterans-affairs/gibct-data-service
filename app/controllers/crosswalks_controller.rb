# frozen_string_literal: true

class CrosswalksController < ApplicationController

  def weams
    @issues = CrosswalkIssue.includes(%i[weam crosswalk ipeds_hd])
                            .issue_source(CrosswalkIssue::WEAMS_SOURCE)
                            .order('weams.institution, weams.facility_code')
  end

  def ipeds
    @issues = CrosswalkIssue.includes(%i[weam crosswalk ipeds_hd])
                            .issue_source(CrosswalkIssue::IPEDS_HDS_SOURCE)
                            .order('ipeds_hds.institution')
  end
end
