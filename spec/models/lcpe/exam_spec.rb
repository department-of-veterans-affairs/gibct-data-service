# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lcpe::Exam, type: :model do
  let(:version) { create :version, :production }
  let(:institution) { create :institution, version_id: version.id }
  let(:facility_code) { institution.facility_code }

  before { create :weam, facility_code: }

  describe 'when validating' do
    it 'has a valid factory' do
      expect(build :lcpe_exam, facility_code:).to be_valid
    end
  end

  describe '.with_enriched_id' do
    before { create :lcpe_exam, facility_code: }

    it 'returns exams with ref_code and enriched_id attribute' do
      exam_enriched = described_class.with_enriched_id.first
      ref = generate_ref_code_from(exam_enriched)
      id = exam_enriched.id.to_s + '@' + ref
      expect(exam_enriched.ref_code).to eq(ref)
      expect(exam_enriched.enriched_id).to eq(id)
    end
  end

  describe '.by_enriched_id' do
    subject(:exam) { create :lcpe_exam, facility_code: }

    let(:ref_code) { generate_ref_code_from(exam) }
    let(:enriched_id) { exam.id.to_s + '@' + ref_code }

    it 'finds Lcpe::Lac by enriched_id' do
      expect(described_class.by_enriched_id(enriched_id).first).to eq(exam)
    end
  end

  describe '.rebuild' do
    it 'generates sql query' do
      sql = described_class.rebuild
      expect(sql).to be_a Lcpe::SqlContext::Sql
    end
  end

  def generate_ref_code_from(exam)
    hash = exam.facility_code + '-' + exam.nexam_nm
    Digest::MD5.hexdigest(hash).last(5)
  end
end
