# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionsArchive, type: :model do
  let(:user) { User.first }
  let(:institutions) { Institution.version(Version.current_preview.number) }

  before(:each) do
    create :user, email: 'fred@va.gov', password: 'fuggedabodit'
  end

  describe 'archive' do
    it 'archives version 1' do

      # version 1
      create_production_version    
      create :institution, version: current_production_number

      # version 2
      create_production_version
      create :institution, version: current_production_number

      puts Institution.all
      puts "delete"
      InstitutionsArchive.delete_all
      puts Institution.all

      expect(Institution.count).to eq(2)
      expect(InstitutionsArchive.count).to eq(0)

      # InstitutionsArchive.archive(Version.current_production)
      
      # expect(Institution.count).to eq(1)
      # expect(Institution.where("version = ?", current_production_number).size).to eq(1)

      # expect(InstitutionsArchive.count).to eq(1)
      # expect(InstitutionsArchive.where("version < ?", current_production_number).size).to eq(1)
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