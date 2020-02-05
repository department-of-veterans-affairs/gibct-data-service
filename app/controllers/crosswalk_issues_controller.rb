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

  def find_matches
    @issue = CrosswalkIssue.find(params[:id])
    address_val = @issue.weam.city + @issue.weam.state + @issue.weam.zip
    #   + " " + @issue.weam.address_2
    #   + " " + @issue.weam.address_3
    #   + " " + @issue.weam.physical_address_1
    # + " " + @issue.weam.physical_address_2
    # + " " + @issue.weam.physical_address_3
    institution_name_results = IpedsHd.where("institution ILIKE ?", "%#{@issue.weam.institution}%")
    address_results = IpedsHd.where("(city||state||zip) ILIKE ?", "%#{address_val}%")
    @ipeds = institution_name_results + address_results
  end

  def match_iped
    crosswalk_issue = CrosswalkIssue.find(params[:issue_id])
    iped = IpedsHd.find(params[:iped_id])
    weam = Weam.find(crosswalk_issue.weam_id)

    if crosswalk_issue.crosswalk_id == nil
      crosswalk = Crosswalk.new
      crosswalk.facility_code = weam.facility_code
      crosswalk.cross = iped.cross
      crosswalk.ope = iped.ope
      crosswalk.city = weam.city
      crosswalk.state = weam.state
      crosswalk.institution = weam.institution
      crosswalk.derive_dependent_columns
      crosswalk.save
    else
      crosswalk = Crosswalk.find(crosswalk_issue.crosswalk_id)
      crosswalk.cross = iped.cross
      crosswalk.ope = iped.ope
      crosswalk.derive_dependent_columns
      crosswalk.save
    end

    crosswalk_issue.destroy

    redirect_to action: :partials
  end

end
