# frozen_string_literal: true

require 'rails_helper'

describe ScorecardDegreeProgramApi::Service do
  describe 'populate scorecard degree programs' do
    let(:result_1) do
      { 'latest.programs.cip_4_digit': [{ unitid: 1, school: {}, credential: {} }] }
    end
    let(:result_2) do
      { 'latest.programs.cip_4_digit': [{ unitid: 2, school: {}, credential: {} }] }
    end

    let(:response_results) { [result_1, result_2] }
    let(:client_instance) { instance_double(ScorecardApi::Client) }

    context 'when calling the api' do
      let(:body) { { results: response_results } }
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
