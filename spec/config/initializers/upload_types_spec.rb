# frozen_string_literal: true

def klass_name(upload)
  klass = upload[:klass]
  return klass if klass.is_a? String

  klass.name
end

RSpec.describe 'UPLOAD_TYPES' do
  describe 'all_tables' do
    it 'lengths should be equal' do
      expect(UPLOAD_TYPES_ALL_NAMES.length).to eq(UPLOAD_TYPES.length)
    end
  end

  describe 'required_table_names' do
    it 'contains tables' do
      UPLOAD_TYPES.each do |upload_type|
        if upload_type[:required?]
          expect(UPLOAD_TYPES_REQUIRED_NAMES).to include(klass_name(upload_type))
        else
          expect(UPLOAD_TYPES_REQUIRED_NAMES).not_to include(klass_name(upload_type))
        end
      end
    end
  end

  describe 'no_prod_names' do
    it 'contains tables' do
      UPLOAD_TYPES.each do |upload_type|
        if upload_type[:not_prod_ready?]
          expect(UPLOAD_TYPES_NO_PROD_NAMES).to include(klass_name(upload_type))
        else
          expect(UPLOAD_TYPES_NO_PROD_NAMES).not_to include(klass_name(upload_type))
        end
      end
    end
  end

  describe 'fields checks' do
    UPLOAD_TYPES.each do |upload|
      it "#{klass_name(upload)} upload type config has field klass" do
        expect(upload[:klass]).to be_a(String).or be < ImportableRecord
      end
    end

    UPLOAD_TYPES.each do |upload|
      it "#{klass_name(upload)} upload type config has field required?" do
        expect(upload[:required?]).to be_in([true, false])
      end
    end

    UPLOAD_TYPES.each do |upload|
      it "#{klass_name(upload)} upload type config not_prod_ready? is a boolean" do
        expect(upload[:not_prod_ready?]).to be_in([true, false]) if upload[:not_prod_ready?].present?
      end
    end
  end
end
