# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe CalculatorConstantsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'calculator_constants'

  describe 'GET #index' do
    login_user

    it 'returns calculator constants' do
      create_list(:calculator_constant, 2)
      get :index
      expect(assigns(:calculator_constants)).to eq(CalculatorConstant.all)
    end
  end

  describe 'POST #update' do
    login_user
    test_rate = 9999.99

    let(:params) do
      {
        calculator_constants: {
          AVGDODBAH: test_rate
        }
      }
    end

    it 'updated calculator constants' do
      create :calculator_constant, :avg_dod_bah_constant
      post(:update, params: params)
      expect(CalculatorConstant.where(name: 'AVGDODBAH')[0].float_value).to eq(test_rate)
    end

    # This is the mechanism that tells the generate version function something changed
    # that needs a new version to be generated
    it 'creates an upload row and sets the columns to expected values' do
      create :calculator_constant, :avg_dod_bah_constant
      post(:update, params: params)
      expect(Upload.count).to eq(1)

      uploade = Upload.last
      expect(uploade.user).to eq current_user
      expect(uploade.csv).to eq 'Gonculator Constants Online'
      expect(uploade.csv_type).to eq 'CalculatorConstant'
      expect(uploade.comment).to eq 'Updated Gonculator Constant value(s)'
      expect(uploade.ok).to eq true
      expect(uploade.completed_at).not_to be nil
      expect(uploade.multiple_file_upload).to eq false
    end
  end
end
