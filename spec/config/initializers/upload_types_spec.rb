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

RSpec.describe 'UPLOAD_TYPES' do
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

  describe 'fields checks' do
    UPLOAD_TYPES.each do |upload|
      it "#{klass_name(upload)} upload type config has field klass" do
        expect(upload[:klass]).to be_a(String).or be < ImportableRecord
      end
    end

    UPLOAD_TYPES.each do |upload|
      it "#{klass_name(upload)} upload type config has field required?" do
        expect(upload[:required?]).to be_in([true, false])
      end
    end

    UPLOAD_TYPES.each do |upload|
      it "#{klass_name(upload)} upload type config not_prod_ready? is a boolean" do
        expect(upload[:not_prod_ready?]).to be_in([true, false]) if upload[:not_prod_ready?].present?
      end
    end
  end
end
