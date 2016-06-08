RSpec.shared_examples "a standardizable model" do |model|
  subject { model.new }

  model.fields.each do |field|
    case field
    when :facility_code
      it "saves the facility_code as an uppercase stripped string" do
        subject.facility_code = "\n  123abc   \n"
        expect(subject.facility_code).to eq('123ABC')
      end

    when :institution
      it "uppercases the institution" do
        subject.institution = "\n  ab cde School   \n"
        expect(subject.institution).to eq('AB CDE SCHOOL')
      end

      it "strips the institution" do
        subject.institution = "\n  ab cde School   \n"
        expect(subject.institution).to eq('AB CDE SCHOOL')
      end

    when :state
      it "saves the state name as a 2 character abbreviation" do
        subject.state = "new york"
        expect(subject.state).to eq("NY")
      end

      it "ignores the state if already abbreviated" do
        subject.state = "NJ"
        expect(subject.state).to eq("NJ")
      end

      it "ignores the state if not a full state name" do
        subject.state = "AbCd"
        expect(subject.state).to eq("AbCd")
      end

    when :ope
      it "it strips leading and trailing blanks from the ope" do
        subject.ope = "\n    00000000    \n"
        expect(subject.ope).to eq("00000000")
      end

      it "an empty ope is saved as nil" do
        subject.ope = "\n     \n"
        expect(subject.ope).to be_nil
      end

      it "saves the ope as a right 0-padded string of at least 8 characters" do
        (1 .. 8).each do |i|
          subject.ope = "0"*i 
          expect(subject.ope).to eq("00000000")
        end

        subject.ope = "0"*9
        expect(subject.ope).to eq("000000000")
      end

    when :ope6
      it "it strips leading and trailing blanks and saves the 2nd through 6th digits of the ope6" do
        subject.ope6 = "\n    12345678    \n"
        expect(subject.ope6).to eq("23456")
      end

      it "an empty ope6 is saved as nil" do
        subject.ope6 = "\n     \n"
        expect(subject.ope6).to be_nil
      end

      it "right 0-pads the ope3 as necessary to 5 characters" do
        subject.ope6 = "12000000"
        expect(subject.ope6).to eq("20000")
      end

    else
      sql_type = model.columns.find { |col| col.name == field.to_s }.sql_type

      it "saves #{field} as a(n) #{sql_type}" do
        if sql_type == "integer"
          subject.send("#{field}=".to_sym, "\n 1000 \n")
          expect(subject.send(field)).to eq(1000)

          subject.send("#{field}=".to_sym, "\n 1000.5 \n")
          expect(subject.send(field)).to eq(1000)
        elsif sql_type == "double precision"
          subject.send("#{field}=".to_sym, "\n 1000 \n")
          expect(subject.send(field)).to eq(1000.0)
            
          subject.send("#{field}=".to_sym, "\n 1000.5 \n")
          expect(subject.send(field)).to eq(1000.5)
        elsif sql_type == "boolean"
          ["true", "t", "yes", "ye", "y", "1", "on", true, 1].each do |v|
            subject.send("#{field}=".to_sym, v)
            expect(subject[field]).to be_truthy
          end
          
          ["false", "f", "no", "n", "0", "off", false, 0].each do |v|
            subject.send("#{field}=".to_sym, v)
            expect(subject[field]).to be_falsy
          end
        else
          expect(subject.send("#{field}=".to_sym, "\n AbCd \n")).to eq("AbCd")                 
        end
      end
    end
  end

  describe "match" do
    context "using a string pattern" do
      it "uses a case insensitive match" do
        expect(model.match "^A.*", "abc").to be_truthy
        expect(model.match "^a.*", "abc").to be_truthy
        expect(model.match "^b.*", "abc").to be_falsy
      end

      it "returns nil when either pattern or value are blank" do
        expect(model.match nil, "abc").to be_falsy
        expect(model.match "", "abc").to be_falsy
        expect(model.match "", "").to be_falsy
        expect(model.match "", nil).to be_falsy
      end
    end

    context "using a regexp pattern" do
      it "matches lowercase if case insensitive" do
        expect(model.match /^A.*/i, "abc").to be_truthy
        expect(model.match /^A.*/, "abc").to be_falsy
      end

      it "returns nil when either pattern or value are blank" do
        expect(model.match nil, nil).to be_falsy
        expect(model.match nil, "").to be_falsy
        expect(model.match nil, "abc").to be_falsy
        expect(model.match /^A.*/, nil).to be_falsy
      end
    end
  end
end