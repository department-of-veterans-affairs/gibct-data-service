require 'rails_helper'

RSpec.describe DS do
  describe "OpeID" do
    subject { DS::OpeId }

    context "pad" do
      %w(1 12 123 1234 12345 123456 1234567 12345678).each do |id|
        ol = id.length
        
        it "pads #{id.length} characters with #{8 - ol} trailing 0s" do
          padded = subject.pad(id)
          expect(padded.length).to eq(8)
          expect(padded[ol, 8 - ol].split('').reject { |p| p == '0' }).to be_blank
        end
      end

      it "ignores ids that eq = 'none'" do
        expect(subject.pad('none')).to eq('none')
      end

      it "ignores nil and blank ids" do
        expect(subject.pad(nil)).to be_nil
        expect(subject.pad('')).to be_blank
      end
    end

    context "to_ope6" do
      %w(1 12 123 1234 12345).each do |id|        
        it "ignores ids that are #{id.length} characters long" do
          expect(subject.to_ope6(id)).to eq(id)
        end
      end

      it "ignores ids that eq = 'none'" do
        expect(subject.to_ope6('none')).to eq('none')
      end

      it "ignores nil and blank ids" do
        expect(subject.to_ope6(nil)).to be_nil
        expect(subject.to_ope6('')).to be_blank
      end
    end

    context "to_location" do
      { '123456' => '100', '1234567' => '170', '12345678' => '178'}.each_pair do |id, loc|   
        it "converts ids #{id.length} long to locations" do
          expect(subject.to_location(id)).to eq(loc)
        end
      end      

      %w(1 12 123 1234 12345).each do |id|        
        it "ignores ids that are #{id.length} characters long" do
          expect(subject.to_location(id)).to eq(id)
        end
      end

      it "ignores ids that eq = 'none'" do
        expect(subject.to_location('none')).to eq('none')
      end

      it "ignores nil and blank ids" do
        expect(subject.to_location(nil)).to be_nil
        expect(subject.to_location('')).to be_blank
      end
    end
  end

  describe "IpedsId" do
    subject { DS::IpedsId }

    context "pad" do
      %w(1 12 123 1234 12345 123456).each do |id|
        ol = id.length
        
        it "pads #{id.length} characters with #{6 - ol} trailing 0s" do
          padded = subject.pad(id)
          expect(padded.length).to eq(6)
          expect(padded[ol, 6 - ol].split('').reject { |p| p == '0' }).to be_blank
        end
      end

      it "ignores ids that eq = 'none'" do
        expect(subject.pad('none')).to eq('none')
      end

      it "ignores nil and blank ids" do
        expect(subject.pad(nil)).to be_nil
        expect(subject.pad('')).to be_blank
      end
    end

    context "vetx_codes" do
      [
        ['not applicable', -2], ['not reported', 1],
        ['implied no', 0], ['yes', 1]
      ].each do |pair|
        it "include the option #{pair.to_s}" do
          expect(subject.vetx_codes).to include(pair)
        end
      end
    end

    context "calsys_codes" do
      [
        ['not applicable', -2], ['semester', 1], 
        ['quarter', 2], ['trimester', 3], 
        ['Four-one-four plan', 4], ['Other academic year', 5],
        ['Differs by program', 6], ['Continuous', 7]
      ].each do |pair|
        it "include the option #{pair.to_s}" do
          expect(subject.calsys_codes).to include(pair)
        end
      end
    end

    context "distncedx_codes" do
      [
        ["not applicable", -2], ['not reported', -1], ['yes', 1], ['no', 2]
      ].each do |pair|
        it "include the option #{pair.to_s}" do
          expect(subject.distncedx_codes).to include(pair)
        end
      end
    end
  end

  describe "Truth" do
    subject { DS::Truth }

    it "nil is not truthy" do
      expect(subject.truthy?(nil)).to be_nil
      expect(subject.truthy?("")).to be_blank
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
    subject { DS::State }

    context "get_names" do
      it "gets a list of abbreviated state names" do
        expect(subject.get_names.class.name).to eq("Array")
        expect(subject.get_names.length).to be >= 59 
      end

      it "only includes valid abbreviated state names" do
        expect(subject.get_names).to include('NY')
        expect(subject.get_names).not_to include('ZZ')
      end
    end

    context "get_full_names" do
      it "gets a list of state names" do
        expect(subject.get_full_names.class.name).to eq("Array")
        expect(subject.get_full_names.length).to be >= 59
      end

      it "only includes valid state names" do
        expect(subject.get_full_names).to include('New York')
        expect(subject.get_full_names).not_to include('Boogerville')
      end
    end

    context "[] operator" do
      it "gets a state's name from its abbreviation" do
        expect(subject['OH']).to eq('Ohio')
      end

      it "gets a state's abbreviation from its full name" do
        expect(subject['Alabama']).to eq('AL')
      end

      it "returns the original name if state is invalid" do
        expect(subject['ZZ']).to eq('ZZ')
        expect(subject['Boogerville']).to eq('Boogerville')
      end
    end

    context "get_random_state" do
      it "gets a random state" do
        sp = subject.get_random_state
        sp_abbrev = sp.to_a[0]

        expect(sp).not_to be_nil
        expect(sp.class.name).to eq("Hash")
        expect(subject::STATES[sp_abbrev]).to eq(sp[sp_abbrev])
      end
    end

    context "get_as_options" do
      it "gets states as select options" do
        opts = subject.get_as_options
        expect(opts.map { |o| o[0] }).to eq(subject::STATES.values)
        expect(opts.map { |o| o[1] }).to eq(subject::STATES.keys)
      end
    end
  end
end