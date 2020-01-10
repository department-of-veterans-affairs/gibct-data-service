require 'rspec'

require_relative '../../app/modules/scorecard_service'

describe ScorecardApi::Service do
  class ResponseClass
    attr_accessor :body
    def initialize(body)
      self.body = body
    end
  end

  let(:result_1) { { :id => '1', :'school.degrees_awarded.predominant' => 0} }
  let(:result_2) { { :id => '2', :'school.degrees_awarded.predominant' => 0} }
  let(:response_results) {[result_1, result_2]}

  describe 'populate' do
    context 'when total is greater than MAGIC_PAGE_NUMBER' do
      let(:total) {ScorecardApi::Service::MAGIC_PAGE_NUMBER + 50}
      let(:body) {{:results => response_results, :metadata => {total: total}}}
      let(:response) { ResponseClass.new(body) }

      it 'calls ScorecardApi::Client twice' do
        allow_any_instance_of(ScorecardApi::Client).to receive(:schools).and_return(response)

        results = ScorecardApi::Service.populate

        expect(results.size).to eq(response_results.size * 2)
      end
    end

    context 'when total is less than MAGIC_PAGE_NUMBER' do
      let(:total) {ScorecardApi::Service::MAGIC_PAGE_NUMBER - 50}
      let(:body) {{:results => response_results, :metadata => {total: total}}}
      let(:response) { ResponseClass.new(body) }

      it 'calls ScorecardApi::Client once' do
        allow_any_instance_of(ScorecardApi::Client).to receive(:schools).and_return(response)

        results = ScorecardApi::Service.populate

        expect(results.size).to eq(response_results.size * 1)
      end
    end
  end
end