# frozen_string_literal: true

require 'rails_helper'

describe ScorecardDegreeProgramApi::Service do
  describe 'populate scorecard degree programs' do
    let(:result_1) do
      {
        'latest.programs.cip_4_digit': [{
          unitid: 1,
          school: {},
          credential: {}
        }]
      }
    end
    let(:result_2) do
      {
        'latest.programs.cip_4_digit': [{
          unitid: 2,
          school: {},
          credential: {}
        }]
      }
    end

    let(:response_results) { [result_1, result_2] }
    let(:client_instance) { instance_double(ScorecardApi::Client) }

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
        expect(results).to all(be_a(ScorecardDegreeProgram))
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
        expect(results).to all(be_a(ScorecardDegreeProgram))
      end
    end
  end
end
