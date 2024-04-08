# frozen_string_literal: true

require 'rails_helper'
require_relative './shared_setup'

RSpec.describe InstitutionBuilder, type: :model do
  include_context('with setup')

  describe 'when calculating category ratings' do
    let(:production_version) { Version.current_production }
    let(:institution) { create(:institution, :physical_address, version_id: production_version.id) }

    before do
      weam = create(:weam, :physical_address, :approved_institution)
      weam.facility_code = '11913105'
      weam.save(validate: false)
      create :institution_school_rating
      create :institution_school_rating, :second_rating
      institution.version = production_version
      institution.facility_code = '11913105'
      institution.save
    end

    it 'counts number of total institution ratings' do
      expect(InstitutionSchoolRating.count).to eq(2)
      described_class.run(user)
      institution2 = Institution.last
      expect(institution2.institution_rating.institution_rating_count).to eq(2)
    end

    it 'counts the number of responses for each question' do
      described_class.run(user)
      institution_rating = Institution.last.institution_rating
      1.upto(14) do |j|
        next if j.eql?(6) # question 6 is yes/no, doesn't get used for ratings

        expect(institution_rating.send("q#{j}_count")).to eq(2)
      end
    end

    it 'averages overall institution rating' do
      described_class.run(user)
      institution2 = Institution.last
      expect(institution2.institution_rating.overall_avg).to eq(1.9)
    end

    it 'calculates the average response for each question' do
      create :institution_school_rating, :third_rating
      described_class.run(user)
      institution_rating = Institution.last.institution_rating
      1.upto(14) do |j|
        next if j.eql?(6) # question 6 is yes/no, doesn't get used for ratings

        expect(institution_rating.send("q#{j}_avg")).to eq(2.0)
      end
    end

    it 'institution rating is null without any ratings' do
      weam = create(:weam, :public, :approved_institution)
      weam.facility_code = '11000001'
      weam.save(validate: false)

      described_class.run(user)
      ins = Institution.where(facility_code: '11000001').first
      expect(ins.institution_rating).to be_nil
    end

    it 'calculates correct average ratings for every main category' do
      described_class.run(user)
      institution2 = Institution.last
      expect(institution2.institution_rating.m1_avg).to eq(2.0)
      expect(institution2.institution_rating.m2_avg).to eq(1.8)
      expect(institution2.institution_rating.m3_avg).to eq(1.8)
      expect(institution2.institution_rating.m4_avg).to eq(2.0)
    end

    it 'does not include null or <=0 in question counts' do
      create :institution_school_rating, :nil_rating
      described_class.run(user)
      institution_rating = Institution.last.institution_rating
      1.upto(14) do |j|
        next if j.eql?(6) # question 6 is yes/no, doesn't get used for ratings

        expect(institution_rating.send("q#{j}_count")).to eq(2) unless j.eql?(14)
        expect(institution_rating.send("q#{j}_count")).to eq(3) if j.eql?(14)
      end
    end

    it 'does not include null or <=0 in average calculations' do
      create :institution_school_rating, :third_rating
      create :institution_school_rating, :nil_rating

      described_class.run(user)
      institution_rating = Institution.last.institution_rating
      1.upto(14) do |j|
        next if j.eql?(6) # question 6 is yes/no, doesn't get used for ratings

        expect(institution_rating.send("q#{j}_avg")).to eq(2.0) unless j.eql?(14)
        expect(institution_rating.send("q#{j}_avg")).to eq(2.3) if j.eql?(14)
      end
    end

    it 'treats values greater than 4 as 4 for calculating averages' do
      create :institution_school_rating, :third_rating
      create :institution_school_rating, :greater_than_4_rating

      described_class.run(user)
      institution_rating = Institution.last.institution_rating
      1.upto(14) do |j|
        next if j.eql?(6) # question 6 is yes/no, doesn't get used for ratings

        expect(institution_rating.send("q#{j}_avg")).to eq(2.5)
      end
    end
  end
end
