# frozen_string_literal: true

RSpec.describe CsvTypes, type: :helper do
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
    CalculatorConstant.name,
    IpedsCipCode.name,
    StemCipCode.name,
    YellowRibbonProgramSource.name,
    SchoolClosure.name,
    Sec109ClosedSchool.name
  ].freeze

  describe 'all_tables' do
    it 'lengths should be equal' do
      expect(CsvTypes.all_tables.length).to eq(CsvTypes::TABLES.length)
    end
  end

  describe 'required_table_names' do
    it 'should contain tables' do
      expect(CsvTypes.required_table_names).to eq(REQUIRED_TABLES)
    end
  end
end
