# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'When creating' do
    context 'with a factory' do
      it 'that factory is valid' do
        expect(create(:user)).to be_valid
      end
    end

    context 'emails' do
      it 'are required' do
        expect { create(:user, :no_email) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'are properly formatted' do
        expect { create :user, :bad_email }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'come from .gov' do
        expect { create :user, :bad_email_domain }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'passwords' do
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
end
