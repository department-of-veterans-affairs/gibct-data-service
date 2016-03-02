require "rails_helper"

require "support/controller_macros"
require "support/devise"
require "support/shared_examples_for_authentication"

RSpec.describe RawFileSourcesController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "raw_file_sources"

  describe "GET index" do
    login_user
    render_views

    before(:each) do
      @rfs = create :raw_file_source
      get :index
    end

    it "populates an array of sources" do
      expect(assigns(:raw_file_sources)).to eq([@rfs])
    end

    it "renders the index page" do
      expect(response).to render_template(:index)
      expect(response.content_type).to eq("text/html")
    end

    it "displays raw file sources" do
      expect(response.body).to match /file_source_/im
    end
  end

  describe "GET new" do
    login_user
    render_views

    before(:each) do
      create :raw_file_source
      get :new
    end

    it "renders the new page" do
      expect(response).to render_template(:new)
      expect(response.content_type).to eq("text/html")
    end

    it "displays empty raw file source form" do
      expect(response.body).to match /create a new raw file source/im
    end
  end

  describe "POST create" do
    login_user
    render_views

    context "with a valid source" do
      before(:each) do
        @rfs = attributes_for :raw_file_source
      end

      it "creates a new raw file source" do
        expect do
          post :create, raw_file_source: @rfs
        end.to change(RawFileSource, :count).by(1)
      end

      it "redirects to the new file source" do
        post :create, raw_file_source: @rfs
        expect(response).to redirect_to RawFileSource.last
      end
    end

    context "with an invalid source" do
      before(:each) do
        @rfs = create :raw_file_source
        @rfs = attributes_for :raw_file_source, name: @rfs.name
      end

      it "does not create a new raw file source" do
        expect do
          post :create, raw_file_source: @rfs
        end.to change(RawFileSource, :count).by(0)
      end

      it "re-renders the new method" do
        post :create, raw_file_source: @rfs
        expect(response).to render_template :new
      end
    end
  end

  describe "GET edit" do
    login_user
    render_views

    before(:each) do
      @rfs = create :raw_file_source
      get :edit, id: @rfs.id
    end

    it "renders the edit page" do
      expect(response).to render_template(:edit)
      expect(response.content_type).to eq("text/html")
    end

    it "displays raw file source form" do
      rxp = Regexp.new("update #{@rfs.name} source", Regexp::IGNORECASE | Regexp::MULTILINE)
      expect(response.body).to match rxp
    end

    it "prefills applicable values" do
      rxp = Regexp.new("value=\"#{@rfs.name}\"", Regexp::IGNORECASE | Regexp::MULTILINE)
      expect(response.body).to match rxp
    end
  end

  describe "PUT update" do
    login_user
    render_views

    context "with a valid source" do
      before(:each) do
        @rfs = create :raw_file_source
      end

      it "replaces the existing raw file source" do
        expect do
          put :update, id: @rfs.id, raw_file_source: { name: @rfs.name }
        end.to change(RawFileSource, :count).by(0)
      end

      it "redirects to the show raw file source" do
        put :update, id: @rfs.id, raw_file_source: { name: @rfs.name }
        expect(response).to redirect_to RawFileSource.last
      end
    end

    context "with an invalid source" do
      before(:each) do
        @rfs1 = create :raw_file_source
        @rfs2 = create :raw_file_source
      end

      it "does not create a new raw file source" do
        expect do
          put :update, id: @rfs2.id,
                       raw_file_source: { name: @rfs1.name, build_order: @rfs2.build_order }
        end.to change(RawFileSource, :count).by(0)
      end

      it "re-renders the edit method" do
        put :update, id: @rfs2.id,
                     raw_file_source: { name: @rfs1.name, build_order: @rfs2.build_order }
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE destroy" do
    login_user
    render_views

    before(:each) do
      @rfs = create :raw_file_source
    end

    it "creates a new raw file source" do
      expect do
        delete :destroy, id: @rfs
      end.to change(RawFileSource, :count).by(-1)
    end

    it "redirects to the index page" do
      delete :destroy, id: @rfs
      expect(response).to redirect_to raw_file_sources_path
    end
  end

  describe "GET show" do
    login_user
    render_views

    before(:each) do
      @rfs = create :raw_file_source
      get :show, id: @rfs.id
    end

    it "populates a source" do
      expect(assigns(:raw_file_source)).to eq(@rfs)
    end

    it "renders the new page" do
      expect(response).to render_template(:show)
      expect(response.content_type).to eq("text/html")
    end

    it "shows the source id and name" do
      expect(response.body).to match Regexp.new(@rfs.id.to_s)
      expect(response.body).to match Regexp.new(@rfs.name)
    end
  end
end
