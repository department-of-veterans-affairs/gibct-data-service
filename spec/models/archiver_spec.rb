# frozen_string_literal: true

require 'rails_helper'

describe '::ARCHIVE_TYPES' do
  context 'when mapped' do
    Archiver::ARCHIVE_TYPES.each do |archivable|
      next if archivable[:archive].blank?

      it "#{archivable[:source].table_name} and #{archivable[:archive].table_name} map correctly" do
        archivable[:source].column_names.each do |column|
          expect(ActiveRecord::Base.connection).to be_column_exists(archivable[:archive].table_name, column)
        end
      end
    end
  end

  # only approved institutions and related data from the previous version are archived. Zip code rates are not tied to
  # institutions, but rather to versions. They are archived. The count changes in the spec reflect this expectation.
  # Caution flags are not archived.
  context 'when archiving' do
    before do
      prev_vsn = create(:version, :production)
      prev_appr_ins = create(:institution, version: prev_vsn)
      create(:institution_program, institution: prev_appr_ins)
      create(:versioned_school_certifying_official, institution: prev_appr_ins)
      create(:zipcode_rate, version: prev_vsn)
      create(:versioned_complaint, version: prev_vsn)

      prev_unapproved = create(:institution, version: prev_vsn, approved: false)
      create(:institution_program, institution: prev_unapproved)
      create(:versioned_school_certifying_official, institution: prev_unapproved)

      curr_vsn = create(:version, :production)
      curr_appr_ins = create(:institution, version: curr_vsn)
      create(:institution_program, institution: curr_appr_ins)
      create(:versioned_school_certifying_official, institution: curr_appr_ins)
      create(:zipcode_rate, version: curr_vsn)
      create(:versioned_complaint, version: curr_vsn)

      curr_unaaproved = create(:institution, version: curr_vsn, approved: false)
      create(:institution_program, institution: curr_unaaproved)
      create(:versioned_school_certifying_official, institution: curr_unaaproved)
    end

    it 'archives only approved institutions & related data & deletes all archivable data from the previous version' do
      expect do
        Archiver.archive_previous_versions
      end.to change(InstitutionsArchive, :count).by(1)
         .and change(InstitutionProgramsArchive, :count).by(1)
         .and change(VersionedSchoolCertifyingOfficialsArchive, :count).by(1)
         .and change(ZipcodeRatesArchive, :count).by(1)
         .and change(VersionedComplaintsArchive, :count).by(1)
         .and change(Institution, :count).by(-2)
         .and change(InstitutionProgram, :count).by(-2)
         .and change(VersionedSchoolCertifyingOfficial, :count).by(-2)
         .and change(ZipcodeRate, :count).by(-1)
         .and change(VersionedComplaint, :count).by(-1)
    end
  end
end
