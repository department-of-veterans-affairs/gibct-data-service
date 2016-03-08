require 'rails_helper'

RSpec.describe RawFileSource, type: :model do
  describe "When creating" do
    context "with a factory" do
      it "that factory is valid" do
        expect(create(:raw_file_source)).to be_valid
      end
    end

    context "csv_file" do
      it "creates an associated csv_file" do
        expect(create(:raw_file_source).csv_file).not_to be_nil
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

  describe "when deleting" do
    context "with associated raw files" do
      subject { create(:weams_file).raw_file_source }

      it "will not delete" do
        expect(subject.destroy).not_to be_truthy
      end

      it "returns an error" do
        subject.destroy
        expect(subject.errors).not_to be_empty
      end
    end

    context "with associated csv data" do  
      subject { create(:raw_file_source) }

     it "deletes the associated csv data too" do
        csv_file_id = subject.csv_file.id

        subject.destroy
        expect(CsvFile.find_by(id: csv_file_id)).to be_nil
      end
    end
  end
end
