# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe AccreditationTypeKeywordsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'accreditation_type_keywords'

  describe 'GET #index' do
    login_user

    context 'when rendering the page' do
      before do
        create(:accreditation_type_keyword)
        create(:accreditation_type_keyword, :accreditation_type_national)
        create(:accreditation_type_keyword, :accreditation_type_hybrid)
        get :index, params: { accreditation_type: 'hybrid' }
      end

      # rubocop:disable RSpec/InstanceVariable
      it 'assigns the passed accreditation type parameter to @accreditation_type' do
        expect(@controller.instance_variable_get(:@accreditation_type)).to eq('hybrid')
      end

      it 'only pulls the accreditation type keyword rows for accreditation type specified' do
        expect(@controller.instance_variable_get(:@accreditation_type_keywords).size).to eq(1)
        expect(
          @controller
            .instance_variable_get(:@accreditation_type_keywords)
            .first
            .accreditation_type
        ).to eq('hybrid')
      end
      # rubocop:enable RSpec/InstanceVariable

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET new' do
    login_user

    context 'when adding a new accreditation type keyword' do
      before do
        get :new, xhr: true, params: { accreditation_type: 'hybrid' }
      end

      # rubocop:disable RSpec/InstanceVariable
      it 'assigns the passed accreditation type parameter to @accreditation_type' do
        expect(@controller.instance_variable_get(:@accreditation_type)).to eq('hybrid')
      end

      it 'instantiates a new accreditation type keyword object' do
        expect(@controller.instance_variable_get(:@accreditation_type_keyword)).not_to be_nil
      end
      # rubocop:enable RSpec/InstanceVariable

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST create' do
    login_user

    context 'with valid form data' do
      it 'creates an accreditation type keyword record' do
        expect do
          post :create, xhr: true, params: {
            accreditation_type_keyword: { accreditation_type: 'hybrid', keyword_match: 'test' }
          }
        end.to change(AccreditationTypeKeyword, :count).by(1)
      end
    end

    context 'with invalid form data' do
      context 'with a blank keyword' do
        it 'renders the new_with_errors js' do
          expect(
            post(
              :create,
              xhr: true,
              params: { accreditation_type_keyword: { accreditation_type: 'hybrid', keyword_match: nil } }
            )
          ).to render_template(:new_with_errors)
        end
      end

      context 'with a duplicate keyword' do
        it 'renders the new_with_errors js' do
          create(:accreditation_type_keyword, :accreditation_type_hybrid)
          expect(
            post(
              :create,
              xhr: true,
              params: { accreditation_type_keyword: {
                accreditation_type: 'hybrid',
                keyword_match: 'midwifery'
              } }
            )
          ).to render_template(:new_with_errors)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    login_user
    context 'when deleting an accreditation type keyword' do
      it 'destroys an accreditation type keyword record' do
        create(:accreditation_type_keyword, :accreditation_type_hybrid)
        expect do
          delete :destroy, xhr: true, params: { id: AccreditationTypeKeyword.first.id }
        end.to change(AccreditationTypeKeyword, :count).by(-1)
      end
    end
  end
end
