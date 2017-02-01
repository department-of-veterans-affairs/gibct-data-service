require 'rails_helper'

RSpec.describe CsvFile, type: :model do
  describe 'when creating' do
    it 'cannot be saved' do
      expect(build :csv_file).not_to be_valid
    end
  end
end
