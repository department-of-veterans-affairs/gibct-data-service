# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_exportable_by_version_history'

RSpec.describe CalculatorConstantVersionsArchive, type: :model do
  before { stub_const("#{described_class.name}::EARLIEST_AVAILABLE_YEAR", 2022) }

  it_behaves_like 'an exportable model by version history'

  describe '.circa' do
    it 'returns most recently versioned records as of a specific year' do
      create_list(:calculator_constant_versions_archive, 2, year: 2023)
      v2023 = create(:version, :from_year, year: 2023)
      records_2023 = create_list(:calculator_constant_versions_archive, 2, version: v2023)

      create_list(:calculator_constant_versions_archive, 2, year: 2024)
      v2024 = create(:version, :from_year, year: 2024)
      records_2024 = create_list(:calculator_constant_versions_archive, 2, version: v2024)

      expect(described_class.circa(2023)).to eq(records_2023)
      expect(described_class.circa(2024)).to eq(records_2024)
    end

    it 'returns empty query if no version exists' do
      create_list(:calculator_constant_versions_archive, 2, year: 2023)
      expect(described_class.circa(2022)).to eq(described_class.none)
    end

    it 'returns published constants instead of archive if querying current year' do
      current_year = Time.zone.now.year
      version = create(:version, :production, :from_year, year: current_year)
      published_constants = create_list(:calculator_constant_version, 2, version:)
      expect(described_class.circa(current_year)).to eq(published_constants)
    end

    # Edge case immediately after New Years
    context 'when year changed but new version has yet to be generated' do
      let(:previous_year) { Time.zone.now.year - 1 }

      before do
        create(:calculator_constant_versions_archive, year: previous_year)
        version = create(:version, :production, :from_year, year: previous_year)
        create(:calculator_constant_version, version:)
      end

      it 'returns published constants instead of archive when querying previous year' do
        expect(described_class.circa(previous_year).first).to be_a(described_class.live_version_klass)
      end

      it 'returns archived constant once a version has been generated in new year' do
        Version.current_production.destroy
        create(:version, :production, :from_year, year: Time.zone.now.year)
        expect(described_class.circa(previous_year).first).to be_a(described_class)
      end
    end
  end

  describe '.over_the_years' do
    before do
      create_list(:calculator_constant_versions_archive, 2, year: 2022)
      create_list(:calculator_constant_versions_archive, 2, year: 2023)
      create_list(:calculator_constant_versions_archive, 2, year: 2024)
    end

    it 'returns most recently versioned records over a range of years' do
      v2022 = create(:version, :production, :from_year, year: 2022)
      records_2022 = create_list(:calculator_constant_versions_archive, 2, version: v2022)

      v2023 = create(:version, :production, :from_year, year: 2023)
      records_2023 = create_list(:calculator_constant_versions_archive, 2, version: v2023)

      v2024 = create(:version, :production, :from_year, year: 2024)
      records_2024 = create_list(:calculator_constant_versions_archive, 2, version: v2024)

      expect(described_class.over_the_years(2022, 2024)).to eq([*records_2022, *records_2023, *records_2024])
      expect(described_class.over_the_years(2023, 2024)).to eq([*records_2023, *records_2024])
    end

    it 'avoids querying versions outside bounds of existing records' do
      # TO-DO: Install timecop gem
      frozen_time = Time.current.change(year: 2024)
      allow(Time.zone).to receive(:now).and_return(frozen_time)
      allow(Version).to receive(:latest_from_year)
      described_class.over_the_years(2019, 2025)
      expect(Version).to have_received(:latest_from_year).exactly(3).times
    end
  end

  describe '.live_version_klass' do
    it 'returns CalculatorConstantVersion' do
      expect(described_class.live_version_klass).to eq(CalculatorConstantVersion)
    end
  end
end
