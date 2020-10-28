# frozen_string_literal: true

def klass_name(upload)
  klass = upload[:klass]
  return klass if klass.is_a? String

  klass.name
end

RSpec.describe 'CSV_TYPES' do
  describe 'all_tables' do
    it 'lengths should be equal' do
      expect(CSV_TYPES_ALL_TABLES_CLASSES.length).to eq(CSV_TYPES_TABLES.length)
    end
  end

  describe 'has_api_table_names' do
    it 'contains tables' do
      CSV_TYPES_TABLES.each do |upload_type|
        if upload_type[:has_api?]
          expect(CSV_TYPES_HAS_API_TABLE_NAMES).to include(klass_name(upload_type))
        else
          expect(CSV_TYPES_HAS_API_TABLE_NAMES).not_to include(klass_name(upload_type))
        end
      end
    end
  end

  describe 'fields checks' do
    CSV_TYPES_TABLES.each do |upload|
      it "#{klass_name(upload)} csv type config has_api? is a boolean" do
        expect(upload[:has_api?]).to be_in([true, false]) if upload.respond_to?(:has_api?)
      end
    end
  end
end
