# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseConverter do
  subject { described_class }

  context 'with strings containing a forbidden word or characters' do
    it 'converts a string composed of a single forbidden word to nil' do
      %w[None NuLl PrIvAcYsUpPrEsSeD .].each do |word|
        expect(described_class.convert(word)).to be_nil
      end
    end

    it 'does not convert a string containing additional words to nil' do
      str = 'null privacysuppressed none'
      expect(described_class.convert(str)).to eq(str)
    end

    it 'strips double quotation marks from strings' do
      str = %("this string has double quotes")
      expect(described_class.convert(str)).to eq('this string has double quotes')
    end
  end

  context 'strings without forbidden words and characters' do
    it 'strips leading and trailing blanks from strings' do
      expect(described_class.convert('     t    ')).to eq('t')
    end

    it 'preserves string case' do
      str = 'a StrIng CONTAINING null And a PERIOD.'
      expect(described_class.convert(str)).to eq(str)
    end

    it 'converts nil to nil' do
      expect(described_class.convert(nil)).to be_nil
    end

    it 'converts strings with only blanks to an empty string' do
      expect(described_class.convert('      ')).to be_blank
    end
  end
end
