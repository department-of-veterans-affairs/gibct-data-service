# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionProgram, type: :model do

  describe 'institution programs' do
    let(:institution) { build :institution }
    it 'correctly returns institution programs' do

      create(:institution, version: 1)
      create(:institution_program, facility_code: institution.facility_code, description: 'TEST', version: 1)
      create(:institution_program, facility_code: institution.facility_code, description: 'TEST', version: 2)

      expect(Institution.count).to eq(1)
      expect(InstitutionProgram.first.facility_code).to eq(institution.facility_code)

      expect(institution.institution_programs.count).to eq(1)

    end
  end
end
