# frozen_string_literal: true

require 'scorecard_api/client'

module ScorecardApi
  class Service
    # per_page is set to the max according to
    # https://github.com/RTICWDT/open-data-maker/blob/master/lib/data_magic/query_builder.rb#L15
    MAX_PAGE_SIZE = 100

    API_MAPPINGS = {
      id: :cross,
      ope8_id: :ope,
      ope6_id: :ope6,
      'school.school_url': :insturl,
      'school.degrees_awarded.predominant': :pred_degree_awarded,
      'school.locale': :locale,
      'school.minority_serving.historically_black': :hbcu,
      'school.men_only': :menonly,
      'school.women_only': :womenonly,
      'school.religious_affiliation': :relaffil,
      'school.under_investigation': :hcm2,
      'school.alias': :alias,
      'latest.aid.federal_loan_rate': :pctfloan,
      'latest.aid.median_debt_suppressed.completers.overall': :avg_stu_loan_debt,
      'latest.completion.rate_suppressed.four_year': :c150_4_pooled_supp,
      'latest.completion.rate_suppressed.lt_four_year_150percent': :c150_l4_pooled_supp,
      'latest.earnings.10_yrs_after_entry.median': :salary_all_students,
      'latest.repayment.3_yr_repayment_suppressed.overall': :repayment_rate_all_students,
      'latest.student.retention_rate.four_year.full_time': :retention_all_students_ba,
      'latest.student.retention_rate.lt_four_year.full_time': :retention_all_students_otb,
      'latest.student.size': :undergrad_enrollment,
      'location.lat': :latitude,
      'location.lon': :longitude,
      'latest.programs.cip_4_digit.unit_id': :unit_id,
      'latest.programs.cip_4_digit.ope6_id': :ope6_id,
      'latest.programs.cip_4_digit.school.type': :control,
      'latest.programs.cip_4_digit.school.main_campus': :main,
      'latest.programs.cip_4_digit.code': :cipcode,
      'latest.programs.cip_4_digit.title': :cipdesc,
      'latest.programs.cip_4_digit.credential.level': :credlev,
      'latest.programs.cip_4_digit.credential.title': :creddesc
    }.freeze

    def self.populate
      results = []

      response_body = schools_api_call(0) #  call for page 0 to get initial @total
      results.push(*response_body[:results])

      number_of_pages = (response_body[:metadata][:total] / MAX_PAGE_SIZE).to_f.ceil

      (1..number_of_pages).each { |page_num| results.push(*schools_api_call(page_num)[:results]) }

      map_results(results)
    end

    def self.schools_api_call(page)
      params = {
        'fields': API_MAPPINGS.keys.join(','),
        'per_page': MAX_PAGE_SIZE.to_s,
        'page': page
      }

      client.schools(params).body
    end

    def self.client
      ScorecardApi::Client.new
    end

    def self.map_results(results)
      degree_programs = []
      scorecard_results = results.map do |result|
        scorecard = Scorecard.new
        result.each_pair { |key, value| 
          if value.kind_of?(Array)
            degree_programs += value
          else
            scorecard[API_MAPPINGS[key]] = value 
          end
        }
        scorecard.derive_dependent_columns
        scorecard
      end
      populate_degree_programs(degree_programs)
      return scorecard_results
    end

    def self.populate_degree_programs(scorecard_degree_programs)
      scorecard_degree_program_results = scorecard_degree_programs.map do |degree_program|
        scorecard_degree_program = ScorecardDegreeProgram.new
        scorecard_degree_program[:unitid] = degree_program[:unit_id]
        scorecard_degree_program[:ope6_id] = degree_program[:ope6_id]
        scorecard_degree_program[:control] = degree_program[:school][:type]
        scorecard_degree_program[:main] = degree_program[:school][:main_campus]
        scorecard_degree_program[:cip_code] = degree_program[:code]
        scorecard_degree_program[:cip_desc] = degree_program[:title]
        scorecard_degree_program[:cred_lev] = degree_program[:credential][:level]
        scorecard_degree_program[:cred_desc] = degree_program[:credential][:title]
        scorecard_degree_program
      end
      ScorecardDegreeProgram.populate(scorecard_degree_program_results)
    end

  end
end
