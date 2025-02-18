# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lcpe::Lac, type: :model do
  let(:version) { create :version, :production }
  let(:institution) { create :institution, version_id: version.id }
  let(:facility_code) { institution.facility_code }

  before { create :weam, facility_code: }

  describe 'when validating' do
    it 'has a valid factory' do
      expect(build(:lcpe_lac, facility_code:)).to be_valid
    end
  end

  describe '.with_enriched_id' do
    before { create :lcpe_lac, facility_code: }

    it 'returns lacs with ref_code and enriched_id attribute' do
      lac_enriched = described_class.with_enriched_id.first
      ref = generate_ref_code_from(lac_enriched)
      id = lac_enriched.id.to_s + '@' + ref
      expect(lac_enriched.ref_code).to eq(ref)
      expect(lac_enriched.enriched_id).to eq(id)
    end
  end

  describe '.by_enriched_id' do
    subject(:lac) { create :lcpe_lac, facility_code: }

    let(:ref_code) { generate_ref_code_from(lac) }
    let(:enriched_id) { lac.id.to_s + '@' + ref_code }

    it 'finds Lcpe::Lac by enriched_id' do
      expect(described_class.by_enriched_id(enriched_id).first).to eq(lac)
    end
  end

  describe '.rebuild' do
    it 'generates sql query' do
      sql = described_class.rebuild
      expect(sql).to be_a Lcpe::SqlContext::Sql
    end
  end

  def generate_ref_code_from(lac)
    hash = lac.facility_code + '-' + lac.lac_nm
    Digest::MD5.hexdigest(hash).last(5)
  end
end
