# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_archive_versionable'

RSpec.describe CalculatorConstantVersionsArchive, type: :model do
  it_behaves_like 'an archive versionable'

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
end
