# frozen_string_literal: true

class CrosswalkIssuesController < ApplicationController
  def partials
    @issues = CrosswalkIssue.includes(%i[weam crosswalk ipeds_hd])
                            .by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE)
                            .order('weams.institution, weams.facility_code')
  end

  def show_partial
    @issue = CrosswalkIssue.find(params[:id])
  end

  # Create or update a Crosswalk in order to resolve the CrosswalkIssue
  def resolve_partial
    @issue = CrosswalkIssue.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).find(params[:id])

    crosswalk = @issue.crosswalk.presence || Crosswalk.new
    crosswalk.facility_code = @issue.weam.facility_code
    crosswalk.institution = @issue.weam.institution
    crosswalk.city = @issue.weam.city
    crosswalk.state = @issue.weam.state
    crosswalk.cross = params['cross']
    crosswalk.ope = params['ope']
    crosswalk.notes = params['notes']
    crosswalk.save

    @issue.crosswalk = crosswalk
    @issue.save

    flash.notice = 'Crosswalk record updated'

    redirect_to action: :show_partial, id: @issue.id
  end

  def orphans
    @issues = CrosswalkIssue.includes(%i[weam crosswalk ipeds_hd])
                            .by_issue_type(CrosswalkIssue::IPEDS_ORPHAN_TYPE)
                            .order('ipeds_hds.institution')
  end
end
