# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionsArchive, type: :model do
  let(:user) { User.first }
  let(:institutions) { Institution.version(Version.current_preview.number) }

  before(:each) do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
  end

  describe 'archive' do
    it 'archives old version without preview versions greater than current production' do

      # version 1
      create_production_version    
      create :institution, version: current_production_number

      # version 2
      create_production_version
      create :institution, version: current_production_number

      expect(Institution.count).to eq(2)
      expect(InstitutionsArchive.count).to eq(0)

      InstitutionsArchive.archive(Version.current_production)
      
      expect(Institution.count).to eq(1)
      expect(Institution.where("version >= ?", current_production_number).size).to eq(1)

      expect(InstitutionsArchive.count).to eq(1)
      expect(InstitutionsArchive.where("version < ?", current_production_number).size).to eq(1)
    end

    it 'archives old version with preview versions greater than current production' do

      # version 1
      create_production_version    
      create :institution, version: current_production_number

      # version 2
      create_production_version
      create :institution, version: current_production_number

      # preview version 3
      create :version, :preview
      create :institution, version: current_preview_number

      expect(Institution.count).to eq(3)
      expect(InstitutionsArchive.count).to eq(0)

      InstitutionsArchive.archive(Version.current_production)
      
      expect(Institution.count).to eq(2)
      expect(Institution.where("version >= ?", current_production_number).size).to eq(2)

      expect(InstitutionsArchive.count).to eq(1)
      expect(InstitutionsArchive.where("version < ?", current_production_number).size).to eq(1)
    end


    it 'archives multiple old versions without preview versions greater than current production' do

      # version 1
      create_production_version    
      create :institution, version: current_production_number

      # version 2
      create_production_version
      create :institution, version: current_production_number
     
      # version 3 
      create_production_version
      create :institution, version: current_production_number

      # version 4
      create_production_version
      create :institution, version: current_production_number

      expect(Institution.count).to eq(4)
      expect(InstitutionsArchive.count).to eq(0)

      InstitutionsArchive.archive(Version.current_production)
      
      expect(Institution.count).to eq(1)
      expect(Institution.where("version >= ?", current_production_number).size).to eq(1)

      expect(InstitutionsArchive.count).to eq(3)
      expect(InstitutionsArchive.where("version < ?", current_production_number).size).to eq(3)
    end

    it 'archives multiple old versions with preview versions greater than current production' do

      # version 1
      create_production_version    
      create :institution, version: current_production_number

      # version 2
      create_production_version
      create :institution, version: current_production_number
     
      # version 3 
      create_production_version
      create :institution, version: current_production_number

      # version 4
      create_production_version
      create :institution, version: current_production_number

      # preview version 5
      create :version, :preview
      create :institution, version: current_preview_number

      expect(Institution.count).to eq(5)
      expect(InstitutionsArchive.count).to eq(0)

      InstitutionsArchive.archive(Version.current_production)
      
      expect(Institution.count).to eq(2)
      expect(Institution.where("version >= ?", current_production_number).size).to eq(2)

      expect(InstitutionsArchive.count).to eq(3)
      expect(InstitutionsArchive.where("version < ?", current_production_number).size).to eq(3)
    end
  end

  # private methods
  private
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