# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YellowRibbonDegreeLevelTranslation, type: :model do
  it 'downcases an raw degree levels' do
    model = described_class.new(raw_degree_level: 'UNDERGRAD', translations: ['Undergraduate'])
    expect { model.save }.to change(described_class, :count).by(1)
    expect(described_class.first.raw_degree_level).to eq('undergrad')
  end

  it 'does not allow invalid translations' do
    model = described_class.new(raw_degree_level: 'aas', translations: ['Undergraduate', 'not_a_real_value'])
    expect { model.save }.not_to change(described_class, :count)
    expect(model.errors[:translations]).not_to be_empty
  end

  it 'does not allow empty lists of translations' do
    model = described_class.new(raw_degree_level: 'aas', translations: [])
    expect { model.save }.not_to change(described_class, :count)
    expect(model.errors[:translations]).not_to be_empty
  end

  describe '::guess_translations' do
    let(:test_values) {
      {
        'undergraduate/graduate' => ['Undergraduate', 'Graduate'],
        'undergraduate/graduate/doctoral' => ['Undergraduate', 'Graduate', 'Doctoral'],
        'undergraduate & graduate' => ['Undergraduate', 'Graduate'],
        'undergraduate' => ['Undergraduate'],
        'graduate' => ['Graduate'],
        'medical lab tech aas	' => ['Associates'],
        'certification' => ['Certificate'],
        'bachelors' => ['Bachelors']
      }
    }

    it 'picks the right translations based on the input string' do
      test_values.each do |input, outputs|
        expect(described_class.guess_translations(input)).to match_array(outputs)
      end
    end
  end
end
