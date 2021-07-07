# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe LatitudeLongitudeIssuesController, type: :controller do
  describe 'GET export' do
    login_user

    it 'causes a CSV to be exported' do
      allow(CensusLatLong).to receive(:export)
      get(:export)
      expect(CensusLatLong).to have_received(:export)
    end

    it 'includes filename parameter in content-disposition header' do
      allow(CensusLatLong).to receive(:export)
      get(:export)
      expect(response.headers['Content-Disposition']).to include('filename="CensusLatLong.zip"')
    end

    it 'displays error' do
      allow(CensusLatLong).to receive(:export).and_raise(StandardError, 'BOOM!')
      get(:export)
      expect(flash[:alert]).to be_present
      expect(flash[:alert]).to match 'BOOM!'
    end
  end

  describe 'GET new' do
    login_user

    context 'when specifying a csv_type' do
      before do
        get :new, params: { csv_type: 'Complaint' }
      end

      it 'assigns skip_lines for Complaint' do
        expect(assigns(:upload).skip_lines).to eq(7)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns extensions' do
        expect(assigns(:extensions)).to include('.xls', '.xlsx', '.csv', '.txt')
      end
    end

    context 'when specifying an invalid csv_type' do
      it 'redirects to the dashboard' do
        expect(get(:new, params: { csv_type: 'FexumGibberit' })).to redirect_to('/dashboards')
      end

      it 'formats an error message in the flash' do
        get :new, params: { csv_type: 'FexumGibberit' }

        expect(flash[:danger]).to be_present
        expect(flash[:danger]).to match('Csv type FexumGibberit is not a valid CSV data source')
      end
    end

    context 'when specifying no csv_type' do
      it 'redirects to the dashboard' do
        expect(
            get(:new)
        ).to redirect_to('/dashboards')
      end

      it 'formats an error message in the flash' do
        get :new

        expect(flash[:danger]).to be_present
        expect(flash[:danger]).to match('Csv type cannot be blank.')
      end
    end

    def requirements(csv_class, requirement_class)
      csv_class.validators
          .find { |requirements| requirements.class == requirement_class }
    end

    def map_attributes(csv_class, requirement_class)
      requirements(csv_class, requirement_class)
          .attributes
          .map { |column| csv_class::CSV_CONVERTER_INFO.select { |_k, v| v[:column] == column }.keys.join(', ') }
    end

    describe 'requirements_messages for Weam' do
      before do
        get :new, params: { csv_type: Weam.name }
      end

      it 'returns validates presence messages' do
        validations_of_str = '|', ','
        message = { message: 'Valid column separators are:', value: validations_of_str }
        expect(assigns(:requirements)).to include(message)
      end

      it 'returns validates numericality messages' do
        validations_of_str = 'current academic year va bah rate'
        message = { message: 'These columns can only contain numeric values: ', value: [validations_of_str] }
        expect(assigns(:requirements)).to include(message)
      end

      it 'returns validates WeamsValidator messages' do
        message = 'Facility codes should be unique'
        # message = { message: 'Requirement Description:', value: [validations_of_str] }
        expect(assigns(:custom_batch_validator)).to include(message)
      end
    end

    describe 'requirements_messages for CalculatorConstant' do
      before do
        get :new, params: { csv_type: CalculatorConstant.name }
      end

      it 'returns validates uniqueness messages' do
        validations_of_str = map_attributes(CalculatorConstant, ActiveRecord::Validations::UniquenessValidator)
        message = { message: 'These columns should contain unique values: ', value: validations_of_str }
        expect(assigns(:requirements)).to include(message)
      end

      it 'returns validates presence messages' do
        validations_of_str = 'name', 'value'
        message = { message: 'These columns must have a value: ', value: validations_of_str }
        expect(assigns(:requirements)).to include(message)
      end
    end
  end

end
