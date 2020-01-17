# frozen_string_literal: true

class CrosswalkIssuesController < ApplicationController
  def show
    @issue = CrosswalkIssue.find(params[:id])
  end

  def partials
    @issues = CrosswalkIssue.includes(%i[weam crosswalk ipeds_hd])
                            .by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE)
                            .order('weams.institution, weams.facility_code')
  end

  def orphans
    @issues = CrosswalkIssue.includes(%i[weam crosswalk ipeds_hd])
                            .by_issue_type(CrosswalkIssue::IPEDS_ORPHAN_TYPE)
                            .order('ipeds_hds.institution')
  end

  def resolve
    issue = CrosswalkIssue.find(params[:id])
    crosswalk = issue.crosswalk.presence || Crosswalk.new
    issue.crosswalk = crosswalk

    crosswalk.facility_code = issue.weam.facility_code
    crosswalk.institution = issue.weam.institution
    crosswalk.city = issue.weam.city
    crosswalk.state = issue.weam.state
    crosswalk.cross = params['cross']
    crosswalk.ope = params['ope']
    crosswalk.notes = params['notes']

    crosswalk.save
    issue.save
    @issue = issue

    flash.notice = 'Crosswalk record updated'

    redirect_to controller: 'crosswalk_issues', action: 'show', id: @issue.id
  end
end
