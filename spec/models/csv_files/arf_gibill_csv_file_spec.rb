require 'rails_helper'
require 'support/shared_examples_for_csv_file_sti'

RSpec.describe ArfGibillCsvFile, type: :model do
  it_behaves_like 'a csv file sti model', :arf_gibill_csv_file

  describe 'when creating an instance' do
    it 'saves uploaded data to the arf_gibill table' do
      csv = build :arf_gibill_csv_file
      expect { csv.save }.to change(ArfGibill, :count).by(2)
    end

    it "does not save if the data doesn't save to arf_gibill" do
      csv = build :arf_gibill_csv_file
      csv.upload.read
      expect { csv.save }.to change(ArfGibill, :count).by(0)
      expect(csv.persisted?).to be_falsy
    end
  end
end
