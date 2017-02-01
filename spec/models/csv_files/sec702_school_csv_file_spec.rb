require 'rails_helper'
require 'support/shared_examples_for_csv_file_sti'

RSpec.describe Sec702SchoolCsvFile, type: :model do
  it_behaves_like 'a csv file sti model', :sec702_school_csv_file

  describe 'when creating an instance' do
    it 'saves uploaded data to the Sec702School table' do
      csv = build :sec702_school_csv_file
      expect { csv.save }.to change(Sec702School, :count).by(2)
    end

    it "does not save if the data doesn't save to Sec702School" do
      csv = build :sec702_school_csv_file
      csv.upload.read
      expect { csv.save }.to change(Sec702School, :count).by(0)
      expect(csv.persisted?).to be_falsy
    end
  end
end
