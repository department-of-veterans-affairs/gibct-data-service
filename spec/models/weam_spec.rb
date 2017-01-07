# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Weam, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :weam }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end
  end

  describe 'offer_degree?' do
    let(:higher_learning_institution) { build :weam, :higher_learning }
    let(:ncd_institution) { build :weam, :ncd }
    let(:non_degree_institution) { build :weam, :non_degree }

    it 'is true if institution of higher learning' do
      expect(higher_learning_institution).to be_offer_degree
    end

    it 'is true if institution offers non-college degree' do
      expect(ncd_institution).to be_offer_degree
    end

    it 'is false if institution does not confer a degree' do
      expect(non_degree_institution).not_to be_offer_degree
    end
  end

  describe 'ojt?' do
    let(:ojt) { build :weam, :ojt }
    let(:non_ojt) { build :weam, :public }

    it 'is true when the school is an ojt institution' do
      expect(ojt).to be_ojt
    end

    it 'is false when the school is not an ojt institution' do
      expect(non_ojt).not_to be_ojt
    end
  end

  describe 'foreign?' do
    let(:foreign) { build :weam, :foreign }
    let(:non_foreign) { build :weam, :public }
    let(:foreign_flight) { build :weam, :flight, country: 'CAN' }
    let(:foreign_correspondence) { build :weam, :correspondence, country: 'CAN' }

    it 'is true when the school is a foreign institution' do
      expect(foreign).to be_foreign
    end

    it 'is false when the school is not a foreign institution' do
      expect(non_foreign).not_to be_foreign
    end

    it 'is false when the foreign school is a flight institution' do
      expect(foreign_flight).not_to be_foreign
    end

    it 'is false when the foreign school is a correspondence institution' do
      expect(foreign_correspondence).not_to be_foreign
    end
  end

  describe 'correspondence?' do
    let(:correspondence) { build :weam, :correspondence }
    let(:higher_learning) { build :weam, :correspondence, :higher_learning }
    let(:ncd_institution) { build :weam, :correspondence, :ncd }
    let(:non_correspondence) { build :weam, :flight }

    it 'is true when the school is a correspondence institution' do
      expect(correspondence).to be_correspondence
    end

    it 'is false when the school is not a correspondence institution' do
      expect(non_correspondence).not_to be_correspondence
    end

    it 'is false when the school is an institution of higher learning' do
      expect(higher_learning).not_to be_correspondence
    end

    it 'is false when the school offers a non-college degree' do
      expect(ncd_institution).not_to be_correspondence
    end
  end

  describe 'flight?' do
    let(:flight) { build :weam, :flight }
    let(:higher_learning) { build :weam, :flight, :higher_learning }
    let(:ncd_institution) { build :weam, :flight, :ncd }
    let(:non_flight) { build :weam, :correspondence }

    it 'is true when the school is a flight institution' do
      expect(flight).to be_flight
    end

    it 'is false when the school is not a flight institution' do
      expect(non_flight).not_to be_flight
    end

    it 'is false when the school is an institution of higher learning' do
      expect(higher_learning).not_to be_flight
    end

    it 'is false when the school offers a non-college degree' do
      expect(ncd_institution).not_to be_flight
    end
  end

  describe 'public?' do
    let(:public_school) { build :weam, :public }
    let(:non_public) { build :weam, :for_profit }
    let(:flight) { build :weam, :flight, :public }
    let(:correspondence) { build :weam, :correspondence, :public }

    it 'is true when the school is a public institution' do
      expect(public_school).to be_public
    end

    it 'is false when the school is not a public institution' do
      expect(non_public).not_to be_public
    end

    it 'is false when the school is a correspondence institution' do
      expect(correspondence).not_to be_public
    end

    it 'is false when the school is a flight institution' do
      expect(flight).not_to be_public
    end
  end

  describe 'for_profit?' do
    let(:profit) { build :weam, :for_profit }
    let(:non_profit) { build :weam, :public }
    let(:flight) { build :weam, :flight, :for_profit }
    let(:correspondence) { build :weam, :correspondence, :for_profit }

    it 'is true when the school is a for profit institution' do
      expect(profit).to be_for_profit
    end

    it 'is false when the school is not a public institution' do
      expect(non_profit).not_to be_for_profit
    end

    it 'is false when the school is a correspondence institution' do
      expect(correspondence).not_to be_for_profit
    end

    it 'is false when the school is a flight institution' do
      expect(flight).not_to be_for_profit
    end
  end

  describe 'private?' do
    let(:private) { build :weam, :private }
    let(:public_school) { build :weam, :public }
    let(:for_profit) { build :weam, :for_profit }

    it 'is true when the school is a private institution' do
      expect(private).to be_private
    end

    it 'is false when the school is either public or for profit' do
      expect(public_school).not_to be_private
      expect(for_profit).not_to be_private
    end
  end

  describe 'type' do
    {
      flight: 'flight', foreign: 'foreign', correspondence: 'correspondence',
      ojt: 'ojt', public: 'public', for_profit: 'for profit', private: 'private'
    }.each_pair do |weam_type, type|
      it "knows its #{type}" do
        weam = build :weam, weam_type
        weam.validate_derived_fields

        expect(weam.institution_type).to eq(type)
      end
    end
  end
end
