# frozen_string_literal: true

REQUIRED_TABLES = [
  AccreditationAction.name,
  AccreditationInstituteCampus.name,
  AccreditationRecord.name,
  ArfGiBill.name,
  Complaint.name,
  Crosswalk.name,
  EightKey.name,
  Hcm.name,
  IpedsHd.name,
  IpedsIcAy.name,
  IpedsIcPy.name,
  IpedsIc.name,
  Mou.name,
  Outcome.name,
  Scorecard.name,
  Sec702.name,
  Sva.name,
  Vsoc.name,
  Weam.name,
  IpedsCipCode.name,
  StemCipCode.name,
  YellowRibbonProgramSource.name,
  Sec109ClosedSchool.name
].freeze

API_TABLES = [
  Scorecard.name
].freeze

NO_PROD_TABLES = [].freeze

RSpec.describe 'CSV_TYPES' do
  describe 'all_tables' do
    it 'lengths should be equal' do
      expect(CSV_TYPES_ALL_TABLES_NAMES.length).to eq(CSV_TYPES_TABLES.length)
    end
  end

  describe 'required_table_names' do
    it 'contains tables' do
      expect(CSV_TYPES_REQUIRED_TABLE_NAMES).to eq(REQUIRED_TABLES)
    end
  end

  describe 'has_api_table_names' do
    it 'contains tables' do
      expect(CSV_TYPES_HAS_API_TABLE_NAMES).to eq(API_TABLES)
    end
  end

  describe 'no_prod_names' do
    it 'contains tables' do
      expect(CSV_TYPES_NO_PROD_NAMES).to eq(NO_PROD_TABLES)
    end
  end
end
