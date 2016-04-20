require 'rails_helper'
require 'support/shared_examples_for_standardizable'

RSpec.describe Complaint, type: :model do
  it_behaves_like "a standardizable model", Complaint

  describe "When creating" do
    describe "with a factory" do
      it "that factory is valid" do
        expect(create(:complaint)).to be_valid
      end
    end

    describe "status" do
      it "is required" do
        expect(build :complaint, status: nil).not_to be_valid
      end

      it "must be from a list of statuses" do
        Complaint::STATUSES.each do |status|
          expect(build :complaint, status: status).to be_valid
        end

        expect(build :complaint, status: "BLAH BLAH").not_to be_valid
      end
    end

    describe "closed_reason" do
      it "must be from a list of closed reasons" do
        Complaint::CLOSED_REASONS.each do |reason|
          expect(build :complaint, closed_reason: reason).to be_valid
        end

        expect(build :complaint, closed_reason: "BLAH BLAH").not_to be_valid
      end
    end
  end

  describe "ok_to_sum?" do
    it "is true only when status is closed and reason is not invalid" do
      Complaint::STATUSES.each do |status|
        Complaint::CLOSED_REASONS.each do |reason|
          complaint = build :complaint, status: status, closed_reason: reason

          expect(complaint.ok_to_sum?).to eq(status == "closed" && reason != "invalid")
        end
      end
    end
  end

  describe "facility_code_terms" do
    Complaint::FAC_CODE_TERMS.each_pair do |term, phrase|
      it "#{term} is 1 if issue contains '#{phrase}'" do
        complaint = create :complaint, :ok_to_sum, issue: "BLAH #{phrase} BLAH"
        expect(complaint[term]).to eq(1)
      end

      it "#{term} is 0 if issue does not contain '#{phrase}'" do
        issue = term == :cfc ? nil : "BLAH BLAH"

        complaint = create :complaint, :ok_to_sum, issue: issue
        expect(complaint[term]).to eq(0)
      end
    end
  end

  describe "update_sums_by_fac" do
    before(:each) do
      create_list :complaint, 10, :all_issues, facility_code: "1"
      Complaint.update_sums_by_fac
    end

    it "each facility code sum is n if there are n issues by that facility code" do
      Complaint.all.each do |complaint|
        Complaint::FAC_CODE_SUMS.keys.each do |fc_sum|
          expect(complaint[fc_sum]).to eq(10)
        end 
      end
    end   
  end

  describe "update_sums_by_ope6" do
    before(:each) do
      create_list :complaint, 10, :all_issues, ope: "11111111"
      Complaint.update_sums_by_ope6
    end

    it "each facility code sum is n if there are n issues by that facility code" do
      Complaint.all.each do |complaint|
        Complaint::OPE6_SUMS.keys.each do |ope6_sum|
          expect(complaint[ope6_sum]).to eq(10)
        end 
      end
    end   
  end
end
