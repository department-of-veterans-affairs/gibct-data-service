# frozen_string_literal: true
RSpec.shared_examples 'a standardizable model' do |model|
  describe '::forbidden_word?' do
    it 'returns true of if a word is not allowed in the data' do
      expect(model.forbidden_word?('NuLl')).to be_truthy
      expect(model.forbidden_word?('nice')).to be_falsey
    end
  end

  describe 'overriding setters' do
    subject { model.new }

    model.column_definitions.each_pair do |col, type|
      case col
      when 'facility_code'
        it ':facility_code capitalizes, trims, and right 0-justifies to 8 places' do
          subject.facility_code = '   abc123    '
          expect(subject.facility_code).to eq('00ABC123')
        end

      when 'institution'
        it ':institution capitalizes and trims names' do
          subject.institution = ' some name    '
          expect(subject.institution).to eq('SOME NAME')
        end

      when 'state'
        it ':state trims and gets the abbreviated-name' do
          subject.state = ' Ny '
          expect(subject.state).to eq('NY')
        end

      when 'ope'
        it ':state capitalizes, trims, and right 0-justifies to 8 places' do
          subject.ope = '   1ab3  '
          expect(subject.ope).to eq('00001AB3')
        end

        it 'adds a getter for ope6' do
          subject.ope = '   1ab3  '
          expect(subject.ope6).to eq('0001A')
        end

      when 'cross'
        it ':cross capitalizes, trims, and right 0-justifies to 6 places' do
          subject.cross = '  ab123   '
          expect(subject.cross).to eq('0AB123')
        end
      else
        case type
        when :boolean
          model::TRUTHY_VALUES.each do |value|
            it ":#{col} converts '#{value}' to true'" do
              subject.send("#{col}=", value)
              expect(subject[col]).to be_truthy
            end
          end
        when :string
          it ":#{col} trims and strips apostrophes" do
            subject.send("#{col}=", " a b c 'd ")
            expect(subject[col]).to eq('a b c d')
          end
        end
      end
    end
  end
end
