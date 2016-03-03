require 'rails_helper'
require "support/shared_examples_for_raw_file_sti"

RSpec.describe RawFile, type: :model do
  it_behaves_like "a raw file sti model", :raw_file

  describe "STI derived classes" do
		before(:all) do
			class FakeChild1 < RawFile; end 
			class FakeChild2 < RawFile; end 
		end

		it "returns a list of child models" do
			fc1 = ['Fake Child1', 'FakeChild1']
			fc2 = ['Fake Child2', 'FakeChild2']

			expect(RawFile.types).to include(fc1, fc2)
		end
	end
end
