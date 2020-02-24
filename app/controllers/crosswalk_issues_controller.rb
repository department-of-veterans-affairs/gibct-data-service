# frozen_string_literal: true

class CrosswalkIssuesController < ApplicationController
  def partials
    @issues = CrosswalkIssue.includes(:crosswalk, :ipeds_hd, weam: :arf_gi_bill)
                            .by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE)
                            .order('arf_gi_bills.gibill desc nulls last, weams.institution, weams.facility_code')
  end

  def show_partial
    @issue = CrosswalkIssue.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).find(params[:id])

    address_data_to_match = @issue.weam.address_values.join
    physical_address_data = @issue.weam.physical_address_values.join
    escaped_institution = ApplicationRecord.connection.quote(@issue.weam.institution)

    str = <<-SQL
        SELECT id, ipeds_hds.cross, institution, addr, state, city, zip, ope, GREATEST(similarity(institution, #{escaped_institution}),
                      similarity((city||state||zip||addr), '#{address_data_to_match}')
                  , similarity((city||state||zip||addr), '#{physical_address_data}')) AS match_score
        FROM ipeds_hds
        WHERE (similarity(institution,  #{escaped_institution}) > 0.5
          OR similarity((city||state||zip||addr), '#{address_data_to_match}') > 0.3
          OR similarity((city||state||zip||addr), '#{physical_address_data}') > 0.3)
        ORDER BY match_score DESC
    SQL
    sql = IpedsHd.sanitize_sql(str)
    @ipeds_hd_arr = ActiveRecord::Base.connection.execute(sql)
  end

  def resolve_partial
    @issue = CrosswalkIssue.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).find(params[:id])

    crosswalk = update_or_create_crosswalk(@issue)
    @issue.crosswalk = crosswalk

    ignore_issue(@issue) if params[:ignore]

    if @issue.resolved? || params[:ignore]
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

  private

  def update_or_create_crosswalk(issue)
    crosswalk = issue.crosswalk.presence || Crosswalk.new
    crosswalk.facility_code = issue.weam.facility_code
    crosswalk.institution = issue.weam.institution
    crosswalk.city = issue.weam.city
    crosswalk.state = issue.weam.state
    crosswalk.cross = params['cross']
    crosswalk.ope = params['ope']
    crosswalk.notes = params['notes']
    crosswalk.save

    crosswalk
  end

  def ignore_issue(issue)
    IgnoredCrosswalkIssue.create(
      cross: issue.ipeds_hd.present? ? issue.ipeds_hd.cross : issue.crosswalk.cross,
      ope: issue.ipeds_hd.present? ? issue.ipeds_hd.ope : issue.crosswalk.ope,
      facility_code: issue.weam.facility_code
    )
  end
end
