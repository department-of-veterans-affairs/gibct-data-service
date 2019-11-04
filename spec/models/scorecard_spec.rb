# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Scorecard, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:scorecard) { build :scorecard }

    let(:by_c150_4_pooled_supp) { create(:scorecard, :by_c150_4_pooled_supp) }
    let(:by_c150_l4_pooled_supp) { create(:scorecard, :by_c150_l4_pooled_supp) }

    it 'has a valid factory' do
      expect(scorecard).to be_valid
    end

    it 'requires a valid cross' do
      expect(build(:scorecard, cross: nil)).not_to be_valid
    end

    it 'will use either the c150_4_pooled_supp or the c150_l4_pooled_supp if only one is present' do
      expect(by_c150_4_pooled_supp.graduation_rate_all_students).to eq(by_c150_4_pooled_supp.c150_4_pooled_supp)
      expect(by_c150_l4_pooled_supp.graduation_rate_all_students).to eq(by_c150_l4_pooled_supp.c150_l4_pooled_supp)
    end

    it 'prefers c150_4_pooled_supp over c150_l4_pooled_supp' do
      expect(scorecard.graduation_rate_all_students).to eq(scorecard.c150_4_pooled_supp)
    end

    it 'requires pred_degree_awarded to be between 0 and 4' do
      expect(build(:scorecard, pred_degree_awarded: nil)).not_to be_valid
      expect(build(:scorecard, pred_degree_awarded: -1)).not_to be_valid
      expect(build(:scorecard, pred_degree_awarded: 5)).not_to be_valid
    end

    it 'requires locale to be in a predefined collection or nil' do
      expect(build(:scorecard, locale: nil)).to be_valid
      expect(build(:scorecard, locale: -4)).not_to be_valid
      expect(build(:scorecard, locale: 0)).not_to be_valid
      expect(build(:scorecard, locale: 44)).not_to be_valid
    end

    it 'requires undergrad_enrollment to be a number or nil' do
      expect(build(:scorecard, undergrad_enrollment: nil)).to be_valid
      expect(build(:scorecard, undergrad_enrollment: 'abc')).not_to be_valid
    end

    it 'requires retention_all_students_ba to be a number or nil' do
      expect(build(:scorecard, retention_all_students_ba: nil)).to be_valid
      expect(build(:scorecard, retention_all_students_ba: 'abc')).not_to be_valid
    end

    it 'requires retention_all_students_otb to be a number or nil' do
      expect(build(:scorecard, retention_all_students_otb: nil)).to be_valid
      expect(build(:scorecard, retention_all_students_otb: 'abc')).not_to be_valid
    end

    it 'requires salary_all_students to be a number or nil' do
      expect(build(:scorecard, salary_all_students: nil)).to be_valid
      expect(build(:scorecard, salary_all_students: 'abc')).not_to be_valid
    end

    it 'requires avg_stu_loan_debt to be a number or nil' do
      expect(build(:scorecard, avg_stu_loan_debt: nil)).to be_valid
      expect(build(:scorecard, avg_stu_loan_debt: 'abc')).not_to be_valid
    end

    it 'requires repayment_rate_all_students to be a number or nil' do
      expect(build(:scorecard, repayment_rate_all_students: nil)).to be_valid
      expect(build(:scorecard, repayment_rate_all_students: 'abc')).not_to be_valid
    end

    it 'requires c150_l4_pooled_supp to be a number or nil' do
      expect(build(:scorecard, c150_l4_pooled_supp: nil)).to be_valid
      expect(build(:scorecard, c150_l4_pooled_supp: 'abc')).not_to be_valid
    end

    it 'requires c150_4_pooled_supp to be a number or nil' do
      expect(build(:scorecard, c150_4_pooled_supp: nil)).to be_valid
      expect(build(:scorecard, c150_4_pooled_supp: 'abc')).not_to be_valid
    end
  end
end
