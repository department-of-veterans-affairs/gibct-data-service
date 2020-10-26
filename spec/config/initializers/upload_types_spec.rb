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

NO_PROD_TABLES = [].freeze

RSpec.describe 'CSV_TYPES' do
  describe 'all_tables' do
    it 'lengths should be equal' do
      expect(UPLOAD_TYPES_ALL_NAMES.length).to eq(UPLOAD_TYPES.length)
    end
  end

  describe 'required_table_names' do
    it 'contains tables' do
      expect(UPLOAD_TYPES_REQUIRED_NAMES).to eq(REQUIRED_TABLES)
    end
  end

  describe 'no_prod_names' do
    it 'contains tables' do
      expect(UPLOAD_TYPES_NO_PROD_NAMES).to eq(NO_PROD_TABLES)
    end
  end
end
