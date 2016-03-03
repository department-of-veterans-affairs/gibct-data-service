require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe RawFilesController, type: :controller do
	it_behaves_like "an authenticating controller", :index, "raw_files"

	describe "GET index" do
		login_user
		render_views

		before(:all) do
			class WeamsFile < RawFile; end 
		end

		before(:each) do
			create :weams_file
			@rfs = RawFile.first

			get :index
		end

		it "populates an array of sources" do
			expect(assigns(:raw_files)).to include(@rfs)
		end

		it "renders the index page" do
			expect(response).to render_template(:index)
			expect(response.content_type).to eq("text/html")
		end

		it "displays raw file sources" do
			expect(response.body).to match /raw_files/im
		end
	end

	describe "GET new" do
		login_user
		render_views

		before(:all) do
			class WeamsFile < RawFile; end 
		end

		before(:each) do
			create :weams_file
			get :new
		end

		it "renders the new page" do
			expect(response).to render_template(:new)
			expect(response.content_type).to eq("text/html")
		end

		it "displays empty raw file source form" do
			expect(response.body).to match /upload a new raw file/im
		end
	end
end
