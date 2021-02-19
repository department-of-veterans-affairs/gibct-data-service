# frozen_string_literal: true

require 'rails_helper'

describe ScorecardApi::Service do
  let(:result_1) { { id: '1', 'school.degrees_awarded.predominant': 0 } }
  let(:result_2) { { id: '2', 'school.degrees_awarded.predominant': 0 } }
  let(:response_results) { [result_1, result_2] }
  let(:client_instance) { instance_double(ScorecardApi::Client) }

  describe 'populate' do
    context 'when total is greater than MAX_PAGE_SIZE' do
      let(:total) { ScorecardApi::Service::MAX_PAGE_SIZE + 50 }
      let(:body) { { results: response_results, metadata: { total: total } } }
      let(:response) do
        response = Faraday::Env.new
        response[:body] = body
        response
      end

      it 'calls ScorecardApi::Client twice' do
        allow(ScorecardApi::Client).to receive(:new).and_return(client_instance)
        allow(client_instance).to receive(:schools).and_return(response)

        results = described_class.populate

        expect(results.size).to eq(response_results.size * 2)
        expect(results).to all(be_a(Scorecard))
      end
    end

    context 'when total is less than MAX_PAGE_SIZE' do
      let(:total) { ScorecardApi::Service::MAX_PAGE_SIZE - 50 }
      let(:body) { { results: response_results, metadata: { total: total } } }
      let(:response) do
        response = Faraday::Env.new
        response[:body] = body
        response
      end

      it 'calls ScorecardApi::Client once' do
        allow(ScorecardApi::Client).to receive(:new).and_return(client_instance)
        allow(client_instance).to receive(:schools).and_return(response)

        results = described_class.populate

        expect(results.size).to eq(response_results.size)
        expect(results).to all(be_a(Scorecard))
      end
    end
  end

  describe 'populate_degree_programs' do
    it 'creates scorecard_degree_programs' do

      degree_programs = [
        {
          :ope6_id=>"000000", 
          :code=>"1", 
          :credential=>{:level=>1, :title=>"title"}, 
          :school=>{:main_campus=>0, :type=>0}, 
          :title=>"title", 
          :unit_id=>1
        }
      ]

      described_class.populate_degree_programs(degree_programs)
      expect(ScorecardDegreeProgram.count()).to eq(degree_programs.size)
    end
  end

end
