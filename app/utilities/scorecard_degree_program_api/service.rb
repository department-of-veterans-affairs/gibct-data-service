# frozen_string_literal: true

require 'scorecard_api/client'

module ScorecardDegreeProgramApi
  class Service < ScorecardApi::Service

    def self.api_mappings
    {
      'latest.programs.cip_4_digit.unit_id': :unit_id,
      'latest.programs.cip_4_digit.ope6_id': :ope6_id,
      'latest.programs.cip_4_digit.school.type': :control,
      'latest.programs.cip_4_digit.school.main_campus': :main,
      'latest.programs.cip_4_digit.code': :cipcode,
      'latest.programs.cip_4_digit.title': :cipdesc,
      'latest.programs.cip_4_digit.credential.level': :credlev,
      'latest.programs.cip_4_digit.credential.title': :creddesc
    }.freeze
    end

    def self.map_results(results)
      degree_program_results = []
      results.map do |result|
        next unless result.key?(:'latest.programs.cip_4_digit')

        result[:'latest.programs.cip_4_digit'].each do |degree_program|
          scorecard_degree_program = ScorecardDegreeProgram.new
          scorecard_degree_program[:unitid] = degree_program[:unit_id]
          scorecard_degree_program[:ope6_id] = degree_program[:ope6_id]
          scorecard_degree_program[:control] = degree_program[:school][:type]
          scorecard_degree_program[:main] = degree_program[:school][:main_campus]
          scorecard_degree_program[:cip_code] = degree_program[:code]
          scorecard_degree_program[:cip_desc] = degree_program[:title]
          scorecard_degree_program[:cred_lev] = degree_program[:credential][:level]
          scorecard_degree_program[:cred_desc] = degree_program[:credential][:title]
          degree_program_results.push(scorecard_degree_program)
        end
      end
      degree_program_results
    end
  end
end
