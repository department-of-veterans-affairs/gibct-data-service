RSpec.shared_examples 'a standardizable model' do |model|
  subject { model.new }

  describe '::forbidden_word?' do
    it 'returns true of if a word is not allowed in the data' do
      expect(model.forbidden_word?('NuLl')).to be_truthy
      expect(model.forbidden_word?('nice')).to be_falsey
    end
  end

  describe '::override_setters' do
    instance = model.new
    
    if instance.respond_to?(:facility_code)
      it 'right justifies and capitalizes facility_code to 8 places' do
        subject.facility_code = 'abc123'
        expect(subject.facility_code).to eq('00ABC123')
      end
    end
  end
end
