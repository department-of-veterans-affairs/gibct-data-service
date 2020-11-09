# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe GroupsController, type: :controller do
  it_behaves_like 'an authenticating controller', :new, 'groups', { group_type: 'Accreditation' }

  describe 'GET new' do
    login_user

    context 'when specifying a csv_type' do
      before do
        get :new, params: { group_type: 'Accreditation' }
      end

      it 'assigns @extensions for Accreditation' do
        expect(assigns(:extensions)).to include('.xls', '.xlsx')
      end

      it 'assigns @@sheets for Accreditation' do
        expect(assigns(:sheets).length).to eq(3)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when specifying an invalid csv_type' do
      it 'redirects to the dashboard' do
        expect(get(:new, params: { group_type: 'FexumGibberit' })).to redirect_to('/dashboards')
      end

      it 'formats an error message in the flash' do
        get :new, params: { group_type: 'FexumGibberit' }

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

    describe 'requirements_messages for Accreditation' do
      before do
        get :new, params: { group_type: 'Accreditation' }
      end

      it 'returns 3 sets of requirements messages' do
        expect(assigns(:requirements).length).to eq(3)
      end

      it 'returns classes for each sheet' do
        sheets = [AccreditationInstituteCampus.name, AccreditationRecord.name, AccreditationAction.name]
        types = assigns(:requirements).map { |r| r[:type] }
        expect(types).to include(*sheets)
      end
    end
  end

  describe 'POST create' do
    let(:upload_file) { build(:group).upload_file }
    let(:sheets) { [AccreditationInstituteCampus.name, AccreditationRecord.name, AccreditationAction.name] }

    login_user

    context 'with having valid form input' do
      it 'Uploads a xlsx file' do
        expect do
          post :create, params: { group: { upload_file: upload_file, skip_lines: ['0'],
                                           comment: 'Test', csv_type: 'Accreditation', sheet_type_list: sheets } }
        end.to change(AccreditationInstituteCampus, :count)
          .by(4).and change(AccreditationRecord, :count)
          .by(4).and change(AccreditationAction, :count).by(4)
      end

      it 'redirects to show' do
        expect(
          post(:create,
               params: {
                 group: { upload_file: upload_file, skip_lines: ['0'],
                          comment: 'Test', csv_type: 'Accreditation', sheet_type_list: sheets }
               })
        ).to redirect_to(action: :show, id: assigns(:group).id)
      end
    end

    context 'with invalid form input' do
      context 'with a non-valid csv_type' do
        it 'renders the new view' do
          expect(
            post(:create,
                 params: {
                   group: { upload_file: upload_file, skip_lines: ['0'],
                            comment: 'Test', csv_type: 'Blah', sheet_type_list: sheets  }
                 })
          ).to render_template(:new)
        end
      end

      context 'with a nil upload file' do
        it 'renders the new view' do
          expect(
            post(:create,
                 params: {
                   group: { upload_file: nil, skip_lines: ['0'],
                            comment: 'Test', csv_type: 'Blah', sheet_type_list: sheets  }
                 })
          ).to render_template(:new)
        end
      end
    end

    context 'with a mal-formed csv file' do
      it 'renders the show view' do
        expect(
          post(:create,
               params: {
                 group: { upload_file: upload_file, skip_lines: ['0'],
                          comment: 'Test', csv_type: 'Accreditation', sheet_type_list: sheets }
               })
        ).to redirect_to(action: :show, id: assigns(:group).id)
      end

      it 'formats a notice message in the flash' do
        post(:create,
             params: { group: { upload_file: upload_file, skip_lines: ['0'],
                                comment: 'Test', csv_type: 'Accreditation', sheet_type_list: sheets } })

        message = flash[:warning][AccreditationInstituteCampus.name][:'The following headers should be checked: ']
                  .try(:first)
        expect(message).to match(/Ipedsunitids is an extra header/)
      end
    end
  end

  describe 'GET show' do
    login_user
    let(:group) { create :group }

    context 'with a valid id' do
      it 'gets the upload instance' do
        get :show, params: { id: group.id }
        expect(assigns(:group)).to eq(group)
      end
    end

    context 'with a invalid id' do
      it 'redirects to uploads index view' do
        expect(get(:show, params: { id: 0 })).to redirect_to('/uploads')
      end
    end
  end
end
