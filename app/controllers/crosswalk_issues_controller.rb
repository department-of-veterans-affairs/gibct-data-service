# frozen_string_literal: true

class CrosswalkIssuesController < ApplicationController
  def partials
    @issues = CrosswalkIssue.includes(:weam, :crosswalk, :ipeds_hd, weam: :arf_gi_bill)
                            .by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE)
                            .order('arf_gi_bills.gibill desc nulls last, weams.institution, weams.facility_code')
  end

  def show_partial
    @issue = CrosswalkIssue.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).find(params[:id])
  end

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

    if @issue.resolved?
      @issue.delete
      flash.notice = 'Crosswalk issue resolved'
      redirect_to action: :partials
    else
      @issue.save
      flash.notice = 'Crosswalk record updated'
      redirect_to action: :show_partial, id: @issue.id
    end
  end

  def orphans
    @issues = CrosswalkIssue.includes(%i[weam crosswalk ipeds_hd])
                            .by_issue_type(CrosswalkIssue::IPEDS_ORPHAN_TYPE)
                            .order('ipeds_hds.institution')
  end
end
