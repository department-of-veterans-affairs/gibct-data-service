# frozen_string_literal: true

require 'models/shared_examples/shared_examples_for_exportable_by_version_history'

RSpec.shared_examples 'an archive versionable' do
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }

  describe '.circa' do
    before do
      create_list(factory_name, 2, year: 2023)
      create_list(factory_name, 2, year: 2024)
    end

    it 'returns most recently versioned records as of a specific year' do
      v2023 = create(:version, :production, :from_year, year: 2023)
      records_2023 = create_list(factory_name, 2, version: v2023)

      v2024 = create(:version, :production, :from_year, year: 2024)
      records_2024 = create_list(factory_name, 2, version: v2024)

      expect(described_class.circa(2023)).to eq(records_2023)
      expect(described_class.circa(2024)).to eq(records_2024)
    end
  end

  describe '.over_the_years' do
    before do
      create_list(factory_name, 2, year: 2022)
      create_list(factory_name, 2, year: 2023)
      create_list(factory_name, 2, year: 2024)
    end

    it 'returns most recentl versioned records over a range of years' do
      v2022 = create(:version, :production, :from_year, year: 2022)
      records_2022 = create_list(factory_name, 2, version: v2022)

      v2023 = create(:version, :production, :from_year, year: 2023)
      records_2023 = create_list(factory_name, 2, version: v2023)

      v2024 = create(:version, :production, :from_year, year: 2024)
      records_2024 = create_list(factory_name, 2, version: v2024)

      expect(described_class.over_the_years(2022, 2024)).to eq([*records_2022, *records_2023, *records_2024])
      expect(described_class.over_the_years(2023, 2024)).to eq([*records_2023, *records_2024])
    end
  end

  describe '.earliest_available_year' do
    it 'returns year where versioning first implemented for record' do
      create(factory_name, year: 2021)
      create(factory_name, year: 2022)
      create(factory_name, year: 2023)

      expect(described_class.earliest_available_year).to eq(2021)
    end

    it 'returns nil if no records available' do
      expect(described_class.earliest_available_year).to eq(nil)
    end
  end
end
