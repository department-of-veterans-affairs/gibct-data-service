require 'rails_helper'

RSpec.describe RawFileSource, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:raw_file_source)).to be_valid
      end
    end

    context "names" do
    	subject { create :raw_file_source }

      it "are required" do
        expect { create(:raw_file_source, :no_name) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "are unique" do
      	expect(build(:raw_file_source, name: subject.name)).not_to be_valid
      end
    end

    context "build_order" do
      subject { create :raw_file_source }

      it "are required" do
        expect { create(:raw_file_source, :no_order) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "are unique" do
        expect(build(:raw_file_source, build_order: subject.build_order)).not_to be_valid
      end

    end
  end
end
