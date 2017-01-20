# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe IpedsIc, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :ipeds_ic }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid cross' do
      expect(build(:ipeds_ic, cross: nil)).not_to be_valid
    end

    describe 'credit_for_mil_training' do
      it 'requires a numerical vet2 in the range (-2..1)' do
        expect(build(:ipeds_ic, vet2: 3)).not_to be_valid
        expect(build(:ipeds_ic, vet2: nil)).not_to be_valid
      end

      it 'is set using 1 as true, 0 as false, -1 and -2 as nil' do
        expect(create(:ipeds_ic, vet2: -2).credit_for_mil_training).to be_nil
        expect(create(:ipeds_ic, vet2: -1).credit_for_mil_training).to be_nil
        expect(create(:ipeds_ic, vet2: 0).credit_for_mil_training).to be_falsey
        expect(create(:ipeds_ic, vet2: 1).credit_for_mil_training).to be_truthy
      end
    end

    describe 'vet_poc' do
      it 'requires a numerical vet3 in the range (-2..1)' do
        expect(build(:ipeds_ic, vet3: 3)).not_to be_valid
        expect(build(:ipeds_ic, vet3: nil)).not_to be_valid
      end

      it 'is set using 1 as true, 0 as false, -1 and -2 as nil' do
        expect(create(:ipeds_ic, vet3: -2).vet_poc).to be_nil
        expect(create(:ipeds_ic, vet3: -1).vet_poc).to be_nil
        expect(create(:ipeds_ic, vet3: 0).vet_poc).to be_falsey
        expect(create(:ipeds_ic, vet3: 1).vet_poc).to be_truthy
      end
    end

    describe 'student_vet_grp_ipeds' do
      it 'requires a numerical vet4 in the range (-2..1)' do
        expect(build(:ipeds_ic, vet4: 3)).not_to be_valid
        expect(build(:ipeds_ic, vet4: nil)).not_to be_valid
      end

      it 'is set using 1 as true, 0 as false, -1 and -2 as nil' do
        expect(create(:ipeds_ic, vet4: -2).student_vet_grp_ipeds).to be_nil
        expect(create(:ipeds_ic, vet4: -1).student_vet_grp_ipeds).to be_nil
        expect(create(:ipeds_ic, vet4: 0).student_vet_grp_ipeds).to be_falsey
        expect(create(:ipeds_ic, vet4: 1).student_vet_grp_ipeds).to be_truthy
      end
    end

    describe 'soc_member' do
      it 'requires a numerical vet5 in the range (-2..1)' do
        expect(build(:ipeds_ic, vet5: 3)).not_to be_valid
        expect(build(:ipeds_ic, vet5: nil)).not_to be_valid
      end

      it 'is set using 1 as true, 0 as false, -1 and -2 as nil' do
        expect(create(:ipeds_ic, vet5: -2).soc_member).to be_nil
        expect(create(:ipeds_ic, vet5: -1).soc_member).to be_nil
        expect(create(:ipeds_ic, vet5: 0).soc_member).to be_falsey
        expect(create(:ipeds_ic, vet5: 1).soc_member).to be_truthy
      end
    end

    describe 'online_all' do
      it 'requires a numerical distnced in [-2, -1, 1, 2]' do
        expect(build(:ipeds_ic, distnced: 0)).not_to be_valid
        expect(build(:ipeds_ic, distnced: nil)).not_to be_valid
      end

      it 'is set using 1 as false, 2 as true, -1 and -2 as nil' do
        expect(create(:ipeds_ic, distnced: -2).online_all).to be_nil
        expect(create(:ipeds_ic, distnced: -1).online_all).to be_nil
        expect(create(:ipeds_ic, distnced: 1).online_all).to be_falsey
        expect(create(:ipeds_ic, distnced: 2).online_all).to be_truthy
      end
    end

    describe 'calendar' do
      it 'requires a numerical calsys in [-2, 1, 2, 3, 4, 5, 6, 7]' do
        expect(build(:ipeds_ic, calsys: 0)).not_to be_valid
        expect(build(:ipeds_ic, calsys: nil)).not_to be_valid
      end

      it 'is set using -2 as nil, 1 as semesters, 2 as quarters, and all else as nontraditional' do
        expect(create(:ipeds_ic, calsys: -2).calendar).to be_nil
        expect(create(:ipeds_ic, calsys: 1).calendar).to eq('semesters')
        expect(create(:ipeds_ic, calsys: 2).calendar).to eq('quarters')
        expect(create(:ipeds_ic, calsys: 3).calendar).to eq('nontraditional')
      end
    end
  end
end
