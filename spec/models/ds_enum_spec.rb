require 'rails_helper'

RSpec.describe DS_ENUM do
  describe "Truth" do
    subject { DS_ENUM::Truth }

    it "nil is not truthy" do
      expect(subject.truthy?(nil)).to eq(false)
      expect(subject.truthy?("")).to eq(false)
    end

    %w(YES Y y Yes yes True true T t 1).each do |t|
      it "'#{t}' is truthy" do
        expect(subject.truthy?(t)).to eq(true)
      end

      it "returns a normalized truth string for '#{t}'" do
        expect(subject.value_to_truth(t)).to eq('yes')
      end
    end

    it "anything other than truthy values are false" do
      expect(subject.truthy?("some string")).to eq(false)
    end

    it "anything other than truthy values is normalized" do
        expect(subject.value_to_truth("some string")).to eq('no')
    end

    it "has a normalizes truth strings" do
      expect(subject.yes).to eq('yes')
      expect(subject.truthy?(subject.yes)).to eq(true)
    end

    it "has a normalizes non-truth strings" do
      expect(subject.no).to eq('no')
      expect(subject.truthy?(subject.no)).to eq(false)
    end
  end

  describe "State" do
    subject { DS_ENUM::State }

    it "gets a list of state abbreviations" do
      expect(subject.get_names.class.name).to eq("Array")
      expect(subject.get_names.length).to be >= 59 
      expect(subject.get_names).to include('NY')
    end

    it "gets a list of state names" do
      expect(subject.get_full_names.class.name).to eq("Array")
      expect(subject.get_full_names.length).to be >= 59
      expect(subject.get_full_names).to include('New York')
    end

    it "gets a state's name from its abbreviation" do
      expect(subject['OH']).to eq('Ohio')
    end

    it "gets a state's abbreviation from its full name" do
      expect(subject['Alabama']).to eq('AL')
    end

    it "gets a random state" do
      sp = subject.get_random_state
      sp_abbrev = sp.to_a[0]

      expect(sp).not_to be_nil
      expect(sp.class.name).to eq("Hash")
      expect(subject::STATES[sp_abbrev]).to eq(sp[sp_abbrev])
    end

    it "gets states as select options" do
      opts = subject.get_as_options
      expect(opts.map { |o| o[0] }).to eq(subject::STATES.values)
      expect(opts.map { |o| o[1] }).to eq(subject::STATES.keys)
    end
  end
end