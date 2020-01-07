# frozen_string_literal: true

require 'scorecard_api/client'

class ScorecardService
  API_MAPPINGS = {
      :id => :cross,
      :ope8_id => :ope,
      :ope6_id => :ope6,
      :'school.school_url' => :insturl,
      :'school.degrees_awarded.predominant' => :pred_degree_awarded,
      :'school.locale' => :locale,
      :'latest.student.size' => :undergrad_enrollment,
      :'latest.student.retention_rate.four_year.full_time' => :retention_all_students_ba,
      :'latest.student.retention_rate.lt_four_year.full_time' => :retention_all_students_otb,
      :'latest.earnings.10_yrs_after_entry.median' => :salary_all_students,
      :'latest.aid.median_debt_suppressed.completers.overall' => :avg_stu_loan_debt,
      :'latest.repayment.3_yr_repayment_suppressed.overall' => :repayment_rate_all_students,
      :'latest.completion.rate_suppressed.four_year' => :c150_4_pooled_supp,
      :'latest.completion.rate_suppressed.lt_four_year_150percent' => :c150_l4_pooled_supp
  }.freeze

  def self.populate
    results = schools.body[:results]
    map_results(results)
  end

  def self.schools
    params = {
      'fields': API_MAPPINGS.keys.join(',')
    }
    client.schools(params)
  end

  def self.client
    ScorecardApi::Client.new
  end

  def self.map_results(results)
    results.map do |result|
      binding.pry
      scorecard = Scorecard.new
      result.each_pair { |key, value| scorecard[API_MAPPINGS[key]] = value }
      scorecard.derive_dependent_columns
      return scorecard
    end
  end
end
