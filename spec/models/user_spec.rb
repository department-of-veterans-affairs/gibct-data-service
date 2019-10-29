# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'When creating' do
    context 'with a factory' do
      it 'that factory is valid' do
        expect(create(:user)).to be_valid
      end
    end

    context 'with emails' do
      it 'are required' do
        expect { create(:user, :no_email) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      # TODO: Add a complex regex or use email verification
      # it 'are properly formatted' do
      #   expect { create :user, :bad_email }.to raise_error(ActiveRecord::RecordInvalid)
      # end
    end

    context 'with passwords' do
      it 'are required' do
        expect { create :user, :no_password }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it '>= 8 characters' do
        expect { create :user, :short_password }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it '<= 72 characters' do
        expect { create :user, :long_password }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'with class methods' do
    let(:vaild_attributes) { { va_eauth_emailaddress: FactoryBot.create(:user).email } }
    let(:empty_attributes) { {} }

    it 'returns a user based on the attributes in the saml response' do
      expect(described_class.from_saml_callback(empty_attributes)).to be_nil
      expect(described_class.from_saml_callback(vaild_attributes)).not_to be_nil
    end
  end
end
