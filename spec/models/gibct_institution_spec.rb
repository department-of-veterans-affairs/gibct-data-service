require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe GibctInstitution, type: :model do
  before(:each) do
    GibctInstitutionType.set_connection('./config/gibct_staging_database.yml')
    GibctInstitution.set_connection('./config/gibct_staging_database.yml')

    GibctInstitutionType.delete_all
    GibctInstitution.delete_all
  end

  after(:each) do
    GibctInstitution.remove_connection
    GibctInstitutionType.remove_connection
  end

  describe 'When creating' do
    subject { create :gibct_institution }

    context 'with a factory' do
      it 'that factory is valid' do
        expect(subject).to be_valid
      end
    end

    context 'institution_type' do
      it 'cannot be blank' do
        expect(build(:gibct_institution, institution_type_id: nil)).not_to be_valid
      end
    end

    context 'facility_code' do
      it 'are unique' do
        expect(build :gibct_institution, facility_code: subject.facility_code).not_to be_valid
      end

      it 'cannot be blank' do
        expect(build(:gibct_institution, facility_code: nil)).not_to be_valid
      end
    end

    describe 'institution' do
      it 'cannot be blank' do
        expect(build(:gibct_institution, institution: nil)).not_to be_valid
      end
    end

    describe 'country' do
      it 'cannot be blank' do
        expect(build(:gibct_institution, country: nil)).not_to be_valid
      end
    end
  end
end
