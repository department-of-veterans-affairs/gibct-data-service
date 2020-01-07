# frozen_string_literal: true

require 'scorecard_api/client'

module ScorecardApi
  class Service

    # per_page is set to the max according to
    # https://github.com/RTICWDT/open-data-maker/blob/master/lib/data_magic/query_builder.rb#L15
    MAGIC_PAGE_NUMBER = 100

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

    def populate
      @results = []
      @results.push(*schools_api_call(0)) #  call for page 0 to get initial @total

      number_of_pages = (@total/MAGIC_PAGE_NUMBER).to_f.ceil

      (1..number_of_pages).each { |page_num|  @results.push(*schools_api_call(page_num)) }

      map_results
    end

    private

    def schools_api_call(page)
      params = {
        'fields': API_MAPPINGS.keys.join(','),
        'per_page': "#{MAGIC_PAGE_NUMBER}",
        'page': page
      }

      response_body = client.schools(params).body
      @total = response_body[:metadata][:total]

      response_body[:results]
    end

    def client
      ScorecardApi::Client.new
    end

    def map_results
      @results.map do |result|
        scorecard = Scorecard.new
        result.each_pair { |key, value| scorecard[API_MAPPINGS[key]] = value }
        scorecard.derive_dependent_columns
        scorecard
      end
    end
  end
end
