# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Complaint, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 7
  it_behaves_like 'an exportable model', skip_lines: 7

  describe 'when validating' do
    subject { Complaint.new(attributes_for(:complaint)) }

    let(:complaint_no_fac_code) { build :complaint, facility_code: nil }
    let(:complaint_no_status) { build :complaint, status: nil }
    let(:complaint_bad_status) { build :complaint, status: 'blech' }
    let(:complaint_bad_reason) { build :complaint, closed_reason: 'blech' }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(complaint_no_fac_code).not_to be_valid
    end

    it 'must have a valid, non-nil status' do
      expect(complaint_no_status).not_to be_valid
      expect(complaint_bad_status).not_to be_valid
    end

    it 'must have a valid closed_reason' do
      expect(complaint_bad_reason).not_to be_valid
    end

    it 'computes the ope6 from the ope' do
      expect(subject.ope6).to eql(subject.ope[1, 5])
    end

    describe 'setting facility code complaints' do
      let(:all) { 'financial quality refund recruit accreditation degree loans grade transfer job transcript other' }
      let(:complaint_all) { build :complaint, issues: all }

      it 'sets complaints to 1 only if the complaint keyword is embedded in the issue' do
        Complaint::COMPLAINT_COLUMNS.each_key do |facility_code_col|
          expect(subject[facility_code_col]).to eq(0)
          expect(complaint_all[facility_code_col]).to eq(1)
        end
      end
    end
  end

  describe 'ok_to_sum?' do
    subject { Complaint.new(attributes_for(:complaint)) }

    let(:invalid) { Complaint.new(attributes_for(:complaint, closed_reason: 'invalid')) }
    let(:nil_reason) { Complaint.new(attributes_for(:complaint, closed_reason: nil)) }
    let(:active) { Complaint.new(attributes_for(:complaint, status: 'active')) }

    it 'is true for a closed complaint with any valid reason' do
      expect(subject).to be_ok_to_sum
    end

    it 'is false for an invalid reason or any non-closed status' do
      expect(invalid).not_to be_ok_to_sum
      expect(nil_reason).not_to be_ok_to_sum
      expect(active).not_to be_ok_to_sum
    end
  end

  describe '#update_ope_from_crosswalk' do
    before(:each) do
      crosswalk = create :crosswalk
      create :complaint, facility_code: crosswalk.facility_code, ope: '00279100'
    end

    it 'replaces the ope with that obtained from the Crosswalk table' do
      Complaint.update_ope_from_crosswalk

      crosswalk = Crosswalk.first
      complaint = Complaint.first

      expect(complaint.ope).to eq(crosswalk.ope)
      expect(complaint.ope6).to eq(crosswalk.ope6)
    end
  end

  describe 'rollup_sums' do
    describe 'by facility_code' do
      before(:each) do
        institution = create :institution, :institution_builder
        create_list :complaint, 2, :all_issues, :institution_builder

        Complaint.rollup_sums(:facility_code, institution.version)
      end

      it 'the facility code sum fields contain the sums grouped by facility_code' do
        institution = Institution.first

        Complaint::FAC_CODE_ROLL_UP_SUMS.each_key do |fc_sum|
          expect(institution[fc_sum]).to eq(2)
        end
      end
    end

    describe 'by ope6' do
      let(:version_number) {}

      before(:each) do
        # Different facility codes, same ope
        institution = create :institution, :institution_builder
        create :institution, :institution_builder, facility_code: 'ZZZZZZZZ'

        # Generate complaints for only one of the facility_codes
        create_list :complaint, 5, :all_issues, :institution_builder
        Complaint.rollup_sums(:ope6, institution.version)
      end

      it 'the institution receives the sums grouped by ope6' do
        Institution.all.each do |institution|
          Complaint::OPE6_ROLL_UP_SUMS.each_key do |ope6_sum|
            expect(institution[ope6_sum]).to eq(5)
          end
        end
      end
    end
  end
end
