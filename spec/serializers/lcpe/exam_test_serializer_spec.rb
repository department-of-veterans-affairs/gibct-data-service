# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lcpe::ExamTestSerializer do
  subject(:serializer) { described_class.new(exam_test) }

  let(:version) { create :version, :production }
  let(:exam_test) { create(:lcpe_exam_test) }

  describe '#serializable_hash' do
    it 'returns the expected serialized hash' do
      expect(serializer.serializable_hash).to eq(
        name: 'AP Exam Fee International',
        fee: '127',
        begin_date: '01-NOV-16',
        end_date: '30-NOV-23'
      )
    end
  end

  describe '#json_key' do
    it 'returns the json key string' do
      expect(serializer.json_key).to eq('exam_test')
    end
  end
end
