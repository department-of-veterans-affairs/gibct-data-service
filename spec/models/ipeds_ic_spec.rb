require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe IpedsIc, type: :model do
  it_behaves_like 'a standardizable model', IpedsIc

  describe 'When creating' do
    context 'with a factory' do
      it 'that factory is valid' do
        expect(create(:ipeds_ic)).to be_valid
      end
    end

    context 'cross' do
      it 'are required' do
        expect(build :ipeds_ic, cross: nil).not_to be_valid
      end
    end

    %w(vet2 vet3 vet4 vet5).each do |col|
      context col do
        it 'is required' do
          expect(build :ipeds_ic, col.to_sym => nil).not_to be_valid
        end

        it 'must be between -2 and 1' do
          [-2, -1, 0, 1].each do |n|
            expect(build :ipeds_ic, col.to_sym => n).to be_valid
          end
        end

        it 'is not valid for numbers less than -2 or greater than 1' do
          expect(build :ipeds_ic, col.to_sym => -3).not_to be_valid
          expect(build :ipeds_ic, col.to_sym => 2).not_to be_valid
        end
      end
    end

    context 'calsys' do
      it 'is required' do
        expect(build :ipeds_ic, calsys: nil).not_to be_valid
      end

      it 'must be one of -2 or [1, 7]' do
        [-2, 1, 2, 3, 4, 5, 6, 7].each do |n|
          expect(build :ipeds_ic, calsys: n).to be_valid
        end
      end

      it 'is not valid for 0, -1 or any number less than -2 or greater than 7' do
        [-3, -1, 0, 8].each do |n|
          expect(build :ipeds_ic, calsys: n).not_to be_valid
        end
      end
    end

    context 'distnced' do
      it 'is required' do
        expect(build :ipeds_ic, distnced: nil).not_to be_valid
      end

      it 'must be one of -2, -1, 1, 2' do
        [-2, -1, 1, 2].each do |n|
          expect(build :ipeds_ic, distnced: n).to be_valid
        end
      end

      it 'is not valid for 0 or any number less than -2 or greater than 2' do
        [-3, 0, 3].each do |n|
          expect(build :ipeds_ic, distnced: n).not_to be_valid
        end
      end
    end
  end

  describe 'derived columns' do
    {
      credit_for_mil_training: :vet2,
      vet_poc: :vet3,
      student_vet_grp_ipeds: :vet4,
      soc_member: :vet5
    }.each_pair do |dcol, ocol|
      context dcol.to_s do
        it "receives the value 'yes' when #{ocol} is 1" do
          expect(create(:ipeds_ic, ocol => 1)[dcol]).to be_truthy
        end

        it "is nil when #{ocol} is not 1" do
          [-2, -1, 0].each do |n|
            expect(create(:ipeds_ic, ocol => n)[dcol]).to be_nil
          end
        end
      end
    end

    context 'calendar' do
      it "equals 'semesters' when calsys is 1" do
        expect(create(:ipeds_ic, calsys: 1).calendar).to eq('semesters')
      end

      it "equals 'quarters' when calsys is 2" do
        expect(create(:ipeds_ic, calsys: 2).calendar).to eq('quarters')
      end

      it "equals 'nontraditional' when calsys > 2" do
        [3, 4, 5, 6, 7].each do |calsys|
          expect(create(:ipeds_ic, calsys: calsys).calendar).to eq('nontraditional')
        end
      end

      it 'is nil when calsys is -2' do
        expect(create(:ipeds_ic, calsys: -2).calendar).to be_nil
      end
    end

    context 'online_all' do
      it "receives the value 'true' when distnced is 1" do
        expect(create(:ipeds_ic, distnced: 1).online_all).to be_truthy
      end

      it 'is nil when distnced is not 1' do
        [-2, -1, 2].each do |n|
          expect(create(:ipeds_ic, distnced: n).online_all).to be_nil
        end
      end
    end
  end
end
