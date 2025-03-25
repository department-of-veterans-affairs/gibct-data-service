# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lcpe::PreloadDataset, type: :model do
  let(:lac_klass) { 'Lcpe::Lac' }
  let(:exam_klass) { 'Lcpe::Exam' }
  let!(:lac_preloads) { create_list(:lcpe_preload_dataset, 2, subject_class: lac_klass) }
  let!(:exam_preloads) { create_list(:lcpe_preload_dataset, 2, subject_class: exam_klass) }

  describe '.of_type' do
    it 'returns preload datasets by LCPE type in descending order' do
      expect(described_class.of_type(lac_klass).to_a).to eq(lac_preloads.reverse)
      expect(described_class.of_type(exam_klass).to_a).to eq(exam_preloads.reverse)
    end

    it 'returns empty array for invalid LCPE type' do
      expect(described_class.of_type('invalid').empty?).to be true
    end
  end

  describe '.stale' do
    it 'returns all preload datasets by type expect most recent' do
      expect(described_class.stale(lac_klass)).to eq(lac_preloads.reverse.drop(1))
    end
  end

  describe '.fresh' do
    it 'returns most recent preload dataset' do
      expect(described_class.fresh(lac_klass)).to eq(lac_preloads.last)
    end
  end

  describe '.build' do
    let(:version) { create(:version, :production) }
    let(:institution) { create(:institution, version_id: version.id) }
    
    before { create(:weam, facility_code: institution.facility_code) }

    it 'deletes stale preload datasets' do
      stale = described_class.stale(lac_klass)
      expect { described_class.build(lac_klass) }.to change { described_class.all.intersect?(stale) }
        .from(true).to(false)
    end

    it 'builds new preload dataset from LCPE type' do
      create(:lcpe_lac, facility_code: institution.facility_code)
      expect { described_class.build(lac_klass) }.to change { described_class.last.id }.by(1)
    end

    it 'stores LCPE dataset with enriched ids as body attribute' do
      lac = create(:lcpe_lac, facility_code: institution.facility_code)
      preload = described_class.build(lac_klass)
      parsed_lac = JSON.parse(preload.body).first
      expect(parsed_lac['id']).to eq(lac.id)
      expect(parsed_lac['enriched_id']).to eq("#{lac.id}v#{preload.id}")
    end
  end
end
