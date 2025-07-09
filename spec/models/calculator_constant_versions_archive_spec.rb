# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalculatorConstantVersionsArchive, type: :model do
  describe 'when validating' do
    subject(:constant_archive) { create(:calculator_constant_versions_archive) }

    it 'has a valid factory' do
      expect(constant_archive).to be_valid
    end

    it 'requires uniqueness' do
      expect(constant_archive.dup).not_to be_valid
    end

    it 'requires presence of name' do
      expect(build(:calculator_constant_versions_archive, name: nil)).not_to be_valid
    end

    it 'requires presence of float value' do
      expect(build(:calculator_constant_versions_archive, float_value: nil)).not_to be_valid
    end
  end

  describe '.circa' do
    # TO-DO: move this to spec for ArchiveVersionable concern
    # let!(:constant_archive) { create(:calculator_constant_versions_archive, version_id: version.id) }
    # let(:version) { create(:version, :production, :from_last_year) }

    # it 'returns all constants belonging to last version as of a specific year' do
    #   previous_year = 1.year.ago.year
    #   expect(described_class.circa(previous_year)).to include(constant_archive)
    # end
  end
end
