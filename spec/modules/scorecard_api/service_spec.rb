# frozen_string_literal: true

require 'rspec'

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

        expect(results.size).to eq(response_results.size * 1)
      end
    end
  end
end
