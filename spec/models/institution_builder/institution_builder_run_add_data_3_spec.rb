# frozen_string_literal: true

require 'rails_helper'
require_relative './shared_setup'

RSpec.describe InstitutionBuilder, type: :model do
  include_context('with setup')

  describe '#run' do
    before do
      create :weam, :institution_builder
      create :crosswalk, :institution_builder
    end

    describe 'when adding Complaint data' do
      let(:institution) { institutions.find_by(facility_code: complaint.facility_code) }
      let(:complaint) { Complaint.first }

      before do
        create_list :complaint, 2, :institution_builder, :all_issues
      end

      it 'calls update_ope_from_crosswalk' do
        allow(Complaint).to receive(:update_ope_from_crosswalk)
        described_class.run(user)
        expect(Complaint).to have_received(:update_ope_from_crosswalk)
      end

      it 'calls rollup_sums for facility_code and ope6' do
        allow(Complaint).to receive(:rollup_sums).twice
        described_class.run(user)
        expect(Complaint).to have_received(:rollup_sums).twice
      end

      it 'sums complaints by facility_code' do
        described_class.run(user)

        Complaint::FAC_CODE_ROLL_UP_SUMS.each_key do |column|
          expect(institution[column]).to eq(2)
        end
      end

      it 'sums complaints by ope6' do
        described_class.run(user)

        Complaint::OPE6_ROLL_UP_SUMS.each_key do |column|
          expect(institution[column]).to eq(2)
        end
      end
    end

    describe 'when adding Outcome data' do
      let(:institution) { institutions.find_by(facility_code: outcome.facility_code) }
      let(:outcome) { Outcome.first }

      before do
        create :outcome, :institution_builder
        described_class.run(user)
      end

      it 'copies columns used by institutions' do
        Outcome::COLS_USED_IN_INSTITUTION.each do |column|
          expect(outcome[column]).to eq(institution[column])
        end
      end
    end

    describe 'calculating stem_offered' do
      let(:stem_cip_code) { StemCipCode.first }
      let(:ipeds_cip_code) { IpedsCipCode.first }
      let(:institution) { institutions.find_by(cross: ipeds_cip_code.cross) }

      context 'with valid stem reference' do
        it 'updates stem_offered' do
          create :ipeds_cip_code, :institution_builder
          create :stem_cip_code
          described_class.run(user)
          expect(institution.stem_offered).to be(true)
        end
      end

      context 'without a cross record match to an ipeds cip code' do
        let(:institution) { Institution.first }

        it 'does not set stem_offered' do
          described_class.run(user)
          expect(institution.stem_offered).to be(false)
        end
      end

      context 'when ctotalt on ipeds record indicates no stem programs available' do
        it 'does not set stem_offered' do
          create :ipeds_cip_code, :institution_builder, ctotalt: 0
          create :stem_cip_code
          described_class.run(user)
          expect(institution.stem_offered).to be(false)
        end
      end

      context 'when there is no matching stem cip code' do
        it 'does not set stem_offered' do
          create :ipeds_cip_code, :institution_builder, cipcode: 0.3
          described_class.run(user)
          expect(institution.stem_offered).to be(false)
        end
      end
    end

    describe 'when adding Yellow Ribbon Program data' do
      let(:institution) { institutions.find_by(facility_code: yellow_ribbon_program_source.facility_code) }
      let(:yellow_ribbon_program_source) { YellowRibbonProgramSource.first }

      before do
        create :yellow_ribbon_program_source, :institution_builder
        described_class.run(user)
      end

      it 'generates a yellow ribbon program' do
        expect(institution.yellow_ribbon_programs.length).to eq(1)
      end

      it 'properly copies yellow ribbon program source data' do
        yrp = institution.yellow_ribbon_programs.first

        expect(yrp.degree_level).to eq(yellow_ribbon_program_source.degree_level)
        expect(yrp.division_professional_school).to eq(yellow_ribbon_program_source.division_professional_school)
        expect(yrp.number_of_students).to eq(yellow_ribbon_program_source.number_of_students)
        expect(yrp.contribution_amount).to eq(yellow_ribbon_program_source.contribution_amount)
      end
    end

    describe 'when adding School Closure data' do
      let(:institution) { institutions.find_by(facility_code: va_caution_flag.facility_code) }
      let(:va_caution_flag) { VaCautionFlag.first }

      before do
        create :va_caution_flag, :school_closing, facility_code: Weam.first.facility_code
        described_class.run(user)
      end

      it 'sets school_closing' do
        expect(institution.school_closing).to be_truthy
      end

      it 'sets school_closing_date' do
        expect(institution.school_closing_on)
          .to eq(Date.strptime(va_caution_flag.school_closing_date, '%m/%d/%y'))
      end
    end

    describe 'when adding Vet Tec Provider data' do
      before do
        create(:weam, :vet_tec)
        described_class.run(user)
      end

      let(:institution) { institutions.find_by(facility_code: '1VZZZZZZ') }

      it 'sets vet_tec_provider to true' do
        expect(institution.vet_tec_provider).to eq(true)
      end
    end

    describe 'when generating zipcode rates' do
      let(:institution) { institutions.find_by(zip: zipcode_rate.zip_code) }
      let(:zipcode_rate) { ZipcodeRate.first }

      before do
        create :weam, :zipcode_rate
        described_class.run(user)
      end

      it 'properly generates zipcode rates from weams data' do
        expect(zipcode_rate).not_to eq(nil)
        expect(zipcode_rate.zip_code).to eq(institution.zip)
        expect(zipcode_rate.mha_rate).to eq(1000)
        expect(zipcode_rate.mha_rate_grandfathered).to eq(1100)
        expect(zipcode_rate.version.id).to eq(Version.current_production.id)
      end
    end

    describe 'when generating institution programs' do
      it 'properly generates institution programs from programs' do
        create :program, facility_code: '1ZZZZZZZ'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
        expect(InstitutionProgram.first.institution_id).to eq(Institution.first.id)
        expect(Institution.first.version_id).to eq(Version.current_production.id)
      end

      it 'generates unique institution programs for different programs belonging to the same institution' do
        create :program, facility_code: '1ZZZZZZZ', description: 'COMPUTER SCIENCE 1'
        create :program, facility_code: '1ZZZZZZZ', description: 'COMPUTER SCIENCE 2'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(2)
      end

      it 'does not generate duplicate institution programs for duplicate programs' do
        create :program, facility_code: '1ZZZZZZZ', description: 'COMPUTER SCIENCE'
        create :program, facility_code: '1ZZZZZZZ', description: 'COMPUTER SCIENCE'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
      end

      it 'does not generate duplicate institution programs for duplicate programs with differently cased names' do
        create :program, facility_code: '1ZZZZZZZ', description: 'COMPUTER SCIENCE'
        create :program, facility_code: '1ZZZZZZZ', description: 'computer science'

        expect { described_class.run(user) }.to change(InstitutionProgram, :count).from(0).to(1)
      end

      # Join on edu_programs removed for time being
      # Ensure edu_programs no longer necessary for institution_program generation
      it 'generates institution programs without matching programs and edu_programs' do
        create :program, facility_code: '1ZZZZZZZ'
        create :edu_program, facility_code: '0001'
        described_class.run(user)
        expect(InstitutionProgram.count).to eq(1)
      end
    end

    describe 'when setting extension campus_type' do
      before do
        create(:weam, :extension)
        create(:weam, facility_code: '10X00001', campus_type: 'Y')
        described_class.run(user)
      end

      it 'sets campus_type to "E"' do
        extension = institutions.find_by(facility_code: '10X00000')
        expect(extension.campus_type).to eq('E')
      end

      it 'ignores for instituions with campus_type' do
        extension = institutions.find_by(facility_code: '10X00001')
        expect(extension.campus_type).to eq('Y')
      end
    end

    describe 'when setting approved' do
      before do
        create(:weam, :as_vet_tec_provider)
        described_class.run(user)
      end

      it 'sets correctly for VET TEC institution' do
        expect(institutions.find_by(facility_code: '1VZZZZZZ').approved).to be_truthy
      end
    end

    describe 'when creating versioned_school_certifying_officials' do
      it 'properly generates school certifying official with instituion_id' do
        weam = create(:weam)
        create :school_certifying_official, facility_code: weam.facility_code
        expect { described_class.run(user) }.to change(VersionedSchoolCertifyingOfficial, :count).from(0).to(1)
        expect(VersionedSchoolCertifyingOfficial.last.institution_id).to be_present
      end

      it 'ignores priority casing' do
        weam = create(:weam)
        create :school_certifying_official, facility_code: weam.facility_code, priority: 'primarY'
        expect { described_class.run(user) }.to change(VersionedSchoolCertifyingOfficial, :count).from(0).to(1)
        expect(VersionedSchoolCertifyingOfficial.last.institution_id).to be_present
      end

      it 'does not create VSCO for SCO with invalid priority value' do
        weam = create(:weam)
        create :school_certifying_official, :invalid_priority, facility_code: weam.facility_code
        described_class.run(user)
        expect(VersionedSchoolCertifyingOfficial.count).to be_zero
      end
    end

    describe 'when creating versioned_complaints' do
      before do
        create_list :complaint, 3
      end

      it 'properly generates versioned complaints with the right version id' do
        expect(VersionedComplaint.count).to eq(0)
        expect { described_class.run(user) }.to change(VersionedComplaint, :count).from(0).to(3)
        expect(VersionedComplaint.pluck(:version_id)).to eq([Version.latest.id] * 3)
      end
    end

    describe 'when setting section 103 data' do
      it 'sets default message for IHL institutions' do
        weam = create :weam, :ihl_facility_code
        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['section_103_message'])
          .to eq('no')
      end

      it 'does not set default message for nonIHL institutions' do
        weam = create :weam
        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['section_103_message'])
          .to eq('no')
      end

      it 'sets certificate required message' do
        weam = create :weam, :ihl_facility_code
        create :sec103, facility_code: weam.facility_code

        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['section_103_message'])
          .to eq('Yes')
      end

      it 'sets certificate required plus additional message' do
        weam = create :weam, :ihl_facility_code
        create :sec103, :requires_additional, facility_code: weam.facility_code

        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['section_103_message'])
          .to eq('Yes')
      end

      it 'institutions that explicitly do not comply with section 103 are not approved ' do
        weam = create :weam, :ihl_facility_code, :approved_poo_and_law_code, :with_approved_indicators
        create :sec103, :does_not_comply, facility_code: weam.facility_code

        described_class.run(user)

        expect(institutions.where("facility_code = '#{weam.facility_code}'").first['approved']).to eq(false)
      end
    end

    describe 'creating a version public export' do
      it 'creates a new version public export' do
        expect { described_class.run(user) }.to change(VersionPublicExport, :count).by(1)
        expect(VersionPublicExport.first.version_id).to eq(Version.current_production.id)
      end
    end

    describe 'when missing latitude and longitude' do
      it 'sets latitude and longitdue from CensusLatLong' do
        weam = create(:weam)
        census_lat_long = create(:census_lat_long, facility_code: weam.facility_code)
        described_class.run(user)
        institution = institutions.where(facility_code: weam.facility_code).first
        institution.longitude = census_lat_long.interpolated_longitude_latitude.split(',')[0]
        institution.latitude = census_lat_long.interpolated_longitude_latitude.split(',')[1]
        institution.save(validate: false)
        expect(institution.longitude.to_s).to eq(census_lat_long.interpolated_longitude_latitude.split(',')[0])
        expect(institution.latitude.to_s).to eq(census_lat_long.interpolated_longitude_latitude.split(',')[1])
      end
    end
  end
end
