require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe IpedsIcPy, type: :model do
  it_behaves_like "a standardizable model", IpedsIcPy
 
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:ipeds_ic_py)).to be_valid
      end
    end

    context "cross" do
      it "are required" do
        expect(build :ipeds_ic_py, cross: nil).not_to be_valid
      end
    end

    context "chg1py3" do
      it "must be an integer" do
        expect(build :ipeds_ic_py, chg1py3: "abc").not_to be_valid
      end    
    end

    context "books" do
      it "must be an integer" do
        expect(build :ipeds_ic_py, books: "abc").not_to be_valid
      end    
    end
  end
end
