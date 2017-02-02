# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Institution, type: :model, focus: true do
  describe 'when validating' do
    subject { build :institution }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:institution, facility_code: nil)).not_to be_valid
    end

    it 'requires a version' do
      expect(build(:institution, version: nil)).not_to be_valid
    end

    it 'requires an institution (name)' do
      expect(build(:institution, institution: nil)).not_to be_valid
    end

    it 'requires a country' do
      expect(build(:institution, country: nil)).not_to be_valid
    end

    it 'requires a valid institution_type_name' do
      expect(build(:institution, institution_type_name: nil)).not_to be_valid
      expect(build(:institution, institution_type_name: 'blah-blah')).not_to be_valid
    end
  end

  describe 'school?' do
    it 'returns true if an institution is not ojt' do
      expect(build(:institution, institution_type_name: 'ojt')).not_to be_school
      expect(build(:institution, institution_type_name: 'private')).to be_school
    end
  end

  describe 'scorecard_link' do
    let(:url) { 'https://collegescorecard.ed.gov/school/?1234567-myschool' }

    it 'returns a url' do
      expect(build(:institution, cross: '1234567', institution: 'myschool').scorecard_link).to eq(url)
    end

    it 'returns nil if the institution is not a school' do
      expect(build(:institution, institution_type_name: 'ojt')).not_to be_nil
    end
  end

  describe 'website_link' do
    let(:url) { 'http://myschool.com' }

    it 'returns a url' do
      expect(build(:institution, insturl: 'myschool.com').website_link).to eq(url)
    end

    it 'returns nil if insturl is blank' do
      expect(build(:institution, insturl: '').website_link).to be_nil
    end
  end

  describe 'vet_website_link' do
    let(:url) { 'http://myschool.com' }

    it 'returns a url' do
      expect(build(:institution, vet_tuition_policy_url: 'myschool.com').vet_website_link).to eq(url)
    end

    it 'returns nil if vet_tuition_policy_url is blank' do
      expect(build(:institution, vet_tuition_policy_url: '').vet_website_link).to be_nil
    end
  end

  describe 'complaints' do
    let(:complaint_fac_code) { build :institution, complaints_facility_code: 1 }

    it 'returns a hash of complaint counts' do
      complaints = complaint_fac_code.complaints
      expect(complaints['facility_code']).to eq(1)

      %w(
        financial_by_fac_code quality_by_fac_code refund_by_fac_code marketing_by_fac_code
        degree_requirements_by_fac_code student_loans_by_fac_code grades_by_fac_code
        credit_transfer_by_fac_code credit_job_by_fac_code job_by_fac_code transcript_by_fac_code
        other_by_fac_code main_campus_roll_up financial_by_ope_id_do_not_sum
        quality_by_ope_id_do_not_sum refund_by_ope_id_do_not_sum marketing_by_ope_id_do_not_sum
        accreditation_by_ope_id_do_not_sum degree_requirements_by_ope_id_do_not_sum
        student_loans_by_ope_id_do_not_sum grades_by_ope_id_do_not_sum
        credit_transfer_by_ope_id_do_not_sum jobs_by_ope_id_do_not_sum
        transcript_by_ope_id_do_not_sum other_by_ope_id_do_not_sum
      ).each do |complaint|
        expect(complaints[complaint]).to be_zero
      end
    end
  end

  describe 'locale_type' do
    it 'maps locale numbers to descriptions' do
      {
        'city' => [11, 12, 13], 'suburban' => [21, 22, 23], 'town' => [31, 32, 33], 'rural' => [41, 42, 43]
      }.each_pair do |description, locales|
        locales.each do |locale|
          expect(build(:institution, locale: locale).locale_type).to eq(description)
        end
      end
    end

    it 'is nil for non-mapped values' do
      expect(build(:institution, locale: 1).locale_type).to be_nil
    end
  end

  describe 'highest_degree' do
    it 'maps pred_degree_awarded to a common value' do
      expect(build(:institution, pred_degree_awarded: 0).highest_degree).to be_nil
      expect(build(:institution, pred_degree_awarded: 1).highest_degree).to eq('Certificate')
      expect(build(:institution, pred_degree_awarded: 2).highest_degree).to eq(2)
      expect(build(:institution, pred_degree_awarded: 3).highest_degree).to eq(4)
      expect(build(:institution, pred_degree_awarded: 4).highest_degree).to eq(4)
    end

    it 'maps va_highest_degree_offered to a common value' do
      expect(build(:institution, va_highest_degree_offered: 0).highest_degree).to be_nil
      expect(build(:institution, va_highest_degree_offered: 'ncd').highest_degree).to eq('Certificate')
      expect(build(:institution, va_highest_degree_offered: '2-year').highest_degree).to eq(2)
      expect(build(:institution, va_highest_degree_offered: '4-year').highest_degree).to eq(4)
    end
  end

  describe '#search' do
    before(:each) do
      create :institution, facility_code: '00000001'
      create_list :institution, 2, :in_chicago
      create :institution, institution: 'HARVARD UNIVERSITY'
    end

    it 'searches schools by facility_code' do
      results = Institution.search('00000001')
      expect(results.count).to eq(1)
      expect(results.first.facility_code).to eq('00000001')
    end

    it 'searches schools by city' do
      results = Institution.search('chicago')
      expect(results.count).to eq(2)
      expect(results.pluck(:city)).to eq(%w(chicago chicago))
    end

    it 'searches schools by name' do
      results = Institution.search('harv')
      expect(results.count).to eq(1)
      expect(results.first.institution).to eq('HARVARD UNIVERSITY')
    end
  end
end
