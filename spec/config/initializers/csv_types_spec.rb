# frozen_string_literal: true

API_TABLES = [
  Scorecard.name
].freeze

RSpec.describe 'CSV_TYPES' do
  describe 'all_tables' do
    it 'lengths should be equal' do
      expect(CSV_TYPES_ALL_TABLES_CLASSES.length).to eq(CSV_TYPES_TABLES.length)
    end
  end

  describe 'has_api_table_names' do
    it 'contains tables' do
      expect(CSV_TYPES_HAS_API_TABLE_NAMES).to eq(API_TABLES)
    end
  end
end
