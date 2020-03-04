# frozen_string_literal: true

class CrosswalkIssuesController < ApplicationController
  def partials
    @issues = CrosswalkIssue.includes(:crosswalk, :ipeds_hd, weam: :arf_gi_bill)
                            .by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE)
                            .order('arf_gi_bills.gibill desc nulls last, weams.institution, weams.facility_code')
  end

  def show_partial
    @issue = CrosswalkIssue.by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE).find(params[:id])
    @possible_ipeds_matches = possible_ipeds_matches(@issue)
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

  # rubocop:disable Metrics/MethodLength
  def possible_ipeds_matches(issue)
    address_data_to_match = ApplicationRecord.connection.quote(issue.weam.address_values_for_match.join)
    physical_address_data = ApplicationRecord.connection.quote(issue.weam.physical_address_values_for_match.join)
    institution = ApplicationRecord.connection.quote(issue.weam.institution)

    str = <<-SQL
        SELECT
          id,
          ipeds_hds.cross,
          institution,
          addr,
          state,
          city,
          zip,
          ope,
          (
            GREATEST(
              SIMILARITY(COALESCE(city,'')||COALESCE(zip,'')||COALESCE(addr,''), #{address_data_to_match}),
              SIMILARITY(COALESCE(city,'')||COALESCE(zip,'')||COALESCE(addr,''), #{physical_address_data})
            )
            + SIMILARITY(institution, #{institution})
          ) / 2 AS match_score
        FROM ipeds_hds
        WHERE
          (
            SIMILARITY(institution, #{institution}) > 0.5
            OR SIMILARITY(COALESCE(city,'')||COALESCE(zip,'')||COALESCE(addr,''), #{address_data_to_match}) > 0.3
            OR SIMILARITY(COALESCE(city,'')||COALESCE(zip,'')||COALESCE(addr,''), #{physical_address_data}) > 0.3
          )
          AND (state = '#{issue.weam.physical_state}' OR state = '#{issue.weam.state}')
        ORDER BY match_score DESC
    SQL
    ApplicationRecord.connection.execute(ApplicationRecord.sanitize_sql(str))
  end
  # rubocop:enable Metrics/MethodLength

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
