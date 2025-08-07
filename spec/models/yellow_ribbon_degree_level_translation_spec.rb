# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YellowRibbonDegreeLevelTranslation, type: :model do
  it 'downcases an raw degree levels' do
    model = described_class.new(raw_degree_level: 'UNDERGRAD', translated_degree_level: 'Undergraduate')
    expect { model.save }.to change(described_class, :count).by(1)
    expect(described_class.first.raw_degree_level).to eq('undergrad')
  end

  it 'does not allow duplicate entries' do
    described_class.create(raw_degree_level: 'aas', translated_degree_level: 'Undergraduate')
    model = described_class.new(raw_degree_level: 'aas', translated_degree_level: 'Undergraduate')
    expect { model.save }.not_to change(described_class, :count)
  end

  it 'only allows valid degree levels' do
    model = described_class.new(raw_degree_level: 'aas', translated_degree_level: 'not_a_real_value')
    expect { model.save }.not_to change(described_class, :count)
  end
end
