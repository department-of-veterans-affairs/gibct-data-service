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
  P911Tf.name,
  P911Yr.name,
  Scorecard.name,
  Sec702School.name,
  Sec702.name,
  Settlement.name,
  Sva.name,
  Vsoc.name,
  Weam.name,
  IpedsCipCode.name,
  StemCipCode.name,
  YellowRibbonProgramSource.name,
  SchoolClosure.name,
  Sec109ClosedSchool.name
].freeze
RSpec.describe 'CSV_TYPES' do
  describe 'all_tables' do
    it 'lengths should be equal' do
      expect(CSV_TYPES_ALL_TABLES.length).to eq(CSV_TYPES_TABLES.length)
    end
  end

  describe 'required_table_names' do
    it 'contains tables' do
      expect(CSV_TYPES_REQUIRED_TABLE_NAMES).to eq(REQUIRED_TABLES)
    end
  end
end
