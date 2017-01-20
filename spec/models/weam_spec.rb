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

    it 'requires facility_code' do
      expect(build(:weam, facility_code: nil)).not_to be_valid
    end

    it 'requires institution' do
      expect(build(:weam, institution: nil)).not_to be_valid
    end

    it 'requires numeric bah if specified' do
      expect(build(:weam, bah: true)).not_to be_valid
    end

    it 'computes the ope6 from ope[1, 5]' do
      subject.valid?
      expect(subject.ope6).to eql(subject.ope[1, 5])
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

  describe 'offer_degree?' do
    let(:higher_learning_institution) { build :weam, :higher_learning }
    let(:ncd_institution) { build :weam, :ncd }
    let(:both) { build :weam, :higher_learning, :ncd }
    let(:neither) { build :weam }

    it 'is true if institution of higher learning, non-college degree granting, or both' do
      expect(higher_learning_institution).to be_offer_degree
      expect(ncd_institution).to be_offer_degree
      expect(both).to be_offer_degree
    end

    it 'is false if institution does not confer a degree' do
      expect(neither).not_to be_offer_degree
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

  describe 'foreign?' do
    let(:foreign) { build :weam, :foreign }
    let(:non_foreign) { build :weam, :public }
    let(:foreign_flight) { build :weam, :flight, :foreign }
    let(:foreign_correspondence) { build :weam, :correspondence, :foreign }

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

  describe 'derive_type' do
    it 'knows its type' do
      [:flight, :foreign, :correspondence, :ojt, :public, :for_profit, :private].each do |type|
        weam = build :weam, type
        weam.valid?

        expect(weam.institution_type).to eq(type.to_s.tr('_', ' '))
      end
    end
  end

  describe 'flags_for_approved?' do
    subject { build :weam, :with_approved_indicators }

    let(:not_approved) { build :weam }

    it 'is true only if at least one indicator flag is set' do
      expect(subject.flags_for_approved?).to be_truthy
      expect(not_approved.flags_for_approved?).to be_falsy
    end
  end

  describe 'approved?' do
    subject { build :weam, :approved_poo_and_law_code, :with_approved_indicators }

    let(:withdrawn) { build :weam, :withdrawn_poo, :with_approved_indicators }
    let(:non_approved_law_code) { build :weam, :approved_poo_and_non_approved_law_code }
    let(:title_31_law_code) { build :weam, :approved_poo_and_non_approved_law_code }
    let(:false_indicators) { build :weam }

    before(:each) do
      subject.valid?
      withdrawn.valid?
      non_approved_law_code.valid?
    end

    it 'is true if poo and law code are approved with at least one true indicator' do
      expect(subject.approved?).to be_truthy
    end

    it 'is false if the poo is withdrawn, or if law code is not approved or title 31' do
      expect(withdrawn.approved?).to be_falsy
      expect(non_approved_law_code.approved?).to be_falsy
      expect(title_31_law_code.approved?).to be_falsy
    end

    it 'is false if there are no truthful indicators' do
      expect(false_indicators.approved?).to be_falsy
    end
  end
end
