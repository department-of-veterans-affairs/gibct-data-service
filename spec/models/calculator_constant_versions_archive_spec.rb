# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_exportable_by_version_history'

RSpec.describe CalculatorConstantVersionsArchive, type: :model do
  before { stub_const("#{described_class.name}::EARLIEST_AVAILABLE_YEAR", 2022) }

  it_behaves_like 'an exportable model by version history'

  describe '.circa' do
    before do
      create_list(:calculator_constant_versions_archive, 2, year: 2023)
      create_list(:calculator_constant_versions_archive, 2, year: 2024)
    end

    it 'returns most recently versioned records as of a specific year' do
      v2023 = create(:version, :production, :from_year, year: 2023)
      records_2023 = create_list(:calculator_constant_versions_archive, 2, version: v2023)

      v2024 = create(:version, :production, :from_year, year: 2024)
      records_2024 = create_list(:calculator_constant_versions_archive, 2, version: v2024)

      expect(described_class.circa(2023)).to eq(records_2023)
      expect(described_class.circa(2024)).to eq(records_2024)
    end

    it 'returns empty query if no version exists' do
      expect(described_class.circa(2019)).to eq(described_class.none)
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

  describe '.source_klass' do
    it 'returns CalculatorConstantVersion' do
      expect(described_class.source_klass).to eq(CalculatorConstantVersion)
    end
  end
end
