require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe Sva, type: :model do
  it_behaves_like "a standardizable model", Sva

  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:sva)).to be_valid
      end
    end
  end

  describe "student_veteran_link" do
    subject { create(:sva, student_veteran_link: "http://www.studentveterans.org") }

    it "sets http://www.studentveterans.org to nil" do
      expect(subject.student_veteran_link).to be_nil
    end
  end
end
