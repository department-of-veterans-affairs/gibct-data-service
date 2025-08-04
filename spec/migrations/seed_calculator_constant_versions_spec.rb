# frozen_string_literal: true

require 'rails_helper'
migration_file = Dir[Rails.root.join('db', 'migrate', '*_seed_calculator_constant_versions.rb')].first
require migration_file

RSpec.describe SeedCalculatorConstantVersions, type: :migration do
  let(:migration) { described_class.new }
  let(:user) { create :user }

  before do
    create(:calculator_constant, :avg_dod_bah_constant)
    create(:version, :production, user: user)
  end

  describe '#up' do
    it 'seeds calculator constant versions' do
      expect { migration.up }.to change(CalculatorConstantVersion, :count).by(1)
    end
  end

  describe '#down' do
    it 'removes calculator constant versions' do
      migration.up
      expect { migration.down }.to change(CalculatorConstantVersion, :count).to(0)
    end
  end
end
