# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionsArchive, type: :model do
  let(:user) { User.first }
  let(:institutions) { Institution.version(Version.current_preview.number) }

  before(:each) do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'

    # version 1
    create_production_version
    create :institution, version: current_production_number

    # version 2
    create_production_version
    create :institution, version: current_production_number
  end

  describe 'archive' do
    it 'archives old version without preview versions greater than current production' do
      initial_institution_count = 2
      institution_count = 1
      institutions_archive_count = 1

      archive_test(initial_institution_count,
                   institution_count,
                   institutions_archive_count)
    end

    it 'archives old version with preview versions greater than current production' do
      # preview version 3
      create :version, :preview
      create :institution, version: current_preview_number

      initial_institution_count = 3
      institution_count = 2
      institutions_archive_count = 1

      archive_test(initial_institution_count,
                   institution_count,
                   institutions_archive_count)
    end

    it 'archives multiple old versions without preview versions greater than current production' do
      # version 3
      create_production_version
      create :institution, version: current_production_number

      # version 4
      create_production_version
      create :institution, version: current_production_number

      initial_institution_count = 4
      institution_count = 1
      institutions_archive_count = 3

      archive_test(initial_institution_count,
                   institution_count,
                   institutions_archive_count)
    end

    it 'archives multiple old versions with preview versions greater than current production' do
      # version 3
      create_production_version
      create :institution, version: current_production_number

      # version 4
      create_production_version
      create :institution, version: current_production_number

      # preview version 5
      create :version, :preview
      create :institution, version: current_preview_number

      initial_institution_count = 5
      institution_count = 2
      institutions_archive_count = 3

      archive_test(initial_institution_count,
                   institution_count,
                   institutions_archive_count)
    end
  end

  # private methods
  private

  def archive_test(initial_institution_count,
                   institution_count,
                   institutions_archive_count)
    expect(Institution.count).to eq(initial_institution_count)
    expect(InstitutionsArchive.count).to eq(0)

    InstitutionsArchive.archive(Version.current_production)

    expect(Institution.count).to eq(institution_count)
    expect(Institution.where('version >= ?', current_production_number).size).to eq(institution_count)

    expect(InstitutionsArchive.count).to eq(institutions_archive_count)
    expect(InstitutionsArchive.where('version < ?', current_production_number).size).to eq(institutions_archive_count)
  end

  def create_production_version
    create :version, :preview
    create :version, :production, number: current_preview_number
  end

  def current_preview_number
    Version.current_preview.number
  end

  def current_production_number
    Version.current_production.number
  end
end
