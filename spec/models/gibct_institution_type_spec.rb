require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe GibctInstitutionType, type: :model do
  before(:each) do 
    GibctInstitutionType.delete_all
    GibctInstitution.delete_all
  end

  it_behaves_like "a standardizable model", GibctInstitutionType

  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:gibct_institution_type)).to be_valid
      end
    end

    context "name" do
      subject { create :gibct_institution_type }

      it "is unique" do
        expect(build :gibct_institution_type, name: subject.name).not_to be_valid
      end

      it "is required" do
        expect(build :gibct_institution_type, name: nil).not_to be_valid
      end
    end
  end
end
