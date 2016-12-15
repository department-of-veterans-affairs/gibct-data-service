RSpec.shared_examples 'a standardizable model' do |model|
  before(:all) { model.connection }

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
        it 'right justifies and capitalizes facility_code to 8 places' do
          subject.facility_code = 'abc123'
          expect(subject.facility_code).to eq('00ABC123')
        end

      when 'institution'
        it 'capitalizes and trims institution names' do
          subject.institution = ' some name    '
          expect(subject.institution).to eq('SOME NAME')
        end
      else
        case type.to_sym
        when :boolean
          model::TRUTHY_VALUES.each do |value|
            it ":#{col} converts '#{value}' to true'" do
              subject[col] = value
              expect(subject[col]).to be_truthy
            end
          end
        end
      end
    end
  end
end
