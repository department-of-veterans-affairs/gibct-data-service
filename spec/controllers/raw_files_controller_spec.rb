require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe RawFilesController, type: :controller do

	#############################################################################
	## generate_create_attributes
	## Generates attributes used in create methods.
	#############################################################################
	def generate_create_attributes(use_upload = true)
		rf = attributes_for :weams_file

		if use_upload
			raw_file = File.new(Rails.root.join('spec/test_data', 'weams_test.csv'))

			rf[:upload] = ActionDispatch::Http::UploadedFile.new(
				tempfile: raw_file, 
				filename: File.basename(raw_file),
				type: 'text/csv'
			)
		end

		rf
	end

	#############################################################################
	## Define constant WeamsFile before any test.
	#############################################################################
	before(:all) do
		class WeamsFile < RawFile; end 
	end

	it_behaves_like "an authenticating controller", :index, "raw_files"

	describe "GET index" do
		login_user
		render_views

		before(:each) do
			create :weams_file
			@rfs = WeamsFile.first

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

	describe "POST create" do
		login_user
		render_views
		
		let(:csv_file) { Rails.root.join('data', WeamsFile.last.name) }
		let(:csv_dir) { Rails.root.join('data') }

		after(:each) do
			File.delete(csv_file) if WeamsFile.last.present? && File.exist?(csv_file)
		end

		context "having valid form input" do
			before(:each) do
				create :weams_file_source
				@rf = generate_create_attributes
			end

			it "creates a new raw_file record" do
				expect{ post :create, raw_file: @rf }.to change(RawFile, :count).by(1)
			end	

			it "adds a new csv file to the server" do
				expect{ post :create, raw_file: @rf }.to change{ Dir.entries(csv_dir).length }.by(1)
			end

			it "deletes the existing older csv file from the server" do
				post :create, raw_file: @rf
				old_weams_file = Rails.root.join('data', WeamsFile.last.name)

				post :create, raw_file: generate_create_attributes
				expect(File.exists?(old_weams_file)).not_to be_truthy
				expect(File.exists?(csv_file)).to be_truthy				
			end

			it "creates a timestamped csv_file" do
				post :create, raw_file: @rf
				expect(File.exist?(csv_file)).to be_truthy
			end

			it "redirects to the show page" do
				post :create, raw_file: @rf
      	expect(response).to redirect_to WeamsFile.last
    	end		
		end

		context "having invalid form input" do
			context "with a non-valid raw_file_source" do
				before(:each) do
					@rf = generate_create_attributes(false)
				end

				it "does not create a new raw_file record" do
					expect{ post :create, raw_file: @rf }.to change(RawFile, :count).by(0)
				end

				it "does not add a new csv file to the server" do
					post :create, raw_file: @rf
					expect{ post :create, raw_file: @rf }.to change{ Dir.entries(csv_dir).length }.by(0)
				end

				it "does not delete the last raw file" do
					create :weams_file_source
					post :create, raw_file: generate_create_attributes
					last_file = Rails.root.join('data', WeamsFile.last.name)

					RawFileSource.last.destroy
					post :create, raw_file: @rf
					expect(File.exist?(last_file)).to be_truthy
				end

				it "re-renders the new method" do
					post :create, raw_file: @rf
      		expect(response).to render_template :new
    		end
			end 	
	
			context "with a invalid upload file" do
				before(:each) do
					create :weams_file_source
					@rf = generate_create_attributes(false)
				end

				it "does not create a new raw_file record" do
					expect{ post :create, raw_file: @rf}.to change(RawFile, :count).by(0)
				end

				it "does not add a new csv file to the server" do
					post :create, raw_file: @rf
					expect{ post :create, raw_file: @rf }.to change{ Dir.entries(csv_dir).length }.by(0)
				end

				it "does not delete the last raw file" do
					post :create, raw_file: generate_create_attributes
					last_file = Rails.root.join('data', WeamsFile.last.name)

					RawFileSource.last.destroy
					post :create, raw_file: @rf
					expect(File.exist?(last_file)).to be_truthy
				end

				it "re-renders the new method" do
					post :create, raw_file: @rf
      		expect(response).to render_template :new
    		end
			end 	
		end
	end

	describe "GET show" do
		login_user
		render_views

		before(:each) do
			@rf = create :weams_file
			get :show, id: @rf.id
		end

		it "populates a raw_file" do
			expect(assigns(:raw_file)).to eq(@rf)
		end

		it "gets the server file name of the latest (weams) raw file" do
			expect(assigns(:csv)).to eq(Rails.root.join('data', @rf.name))
		end

		it "renders the new page" do
			expect(response).to render_template(:show)
			expect(response.content_type).to eq("text/html")
		end		

		it "shows the id, server name, and other fields" do
			expect(response.body).to match Regexp.new(@rf.id.to_s)
			expect(response.body).to match Regexp.new(@rf.name)
			expect(response.body).to match Regexp.new(@rf.raw_file_source.name)
			expect(response.body).to match Regexp.new(@rf.upload_date.strftime("%B %d, %Y"))
		end
	end

	describe "GET edit" do
		login_user
		render_views

		before(:each) do
			@rf = create :weams_file
			get :edit, id: @rf.id
		end

		it "renders the edit page" do
			expect(response).to render_template(:edit)
			expect(response.content_type).to eq("text/html")
		end

		it "displays raw file source form" do
			rxp = Regexp.new("update #{@rf.name}", Regexp::IGNORECASE | Regexp::MULTILINE)
			expect(response.body).to match rxp
		end

		it "prefills applicable values" do
			expect(response.body).to match /selected="selected" value="WeamsFile"/
		end
	end

	describe "PUT update" do
		login_user
		render_views
		
		let(:csv_file) { Rails.root.join('data', WeamsFile.last.name) }
		let(:csv_dir) { Rails.root.join('data') }

		after(:each) do
			File.delete(csv_file) if WeamsFile.last.present? && File.exist?(csv_file)
		end

		context "having valid form input" do
			let(:last_weams_file_id) { WeamsFile.last.id }
			
			before(:each) do
				create :weams_file_source

				post :create, raw_file: generate_create_attributes
				@old_weams_file = Rails.root.join('data', WeamsFile.last.name)

				@rf = generate_create_attributes
			end

			it "doesn't create a new raw_file record" do
				expect{ 
					put :update, id: last_weams_file_id, 
					raw_file: { type: @rf[:type], upload: @rf[:upload] } 
				}.to change(RawFile, :count).by(0)
			end	

			it "deletes the existing older csv file from the server" do
				put :update, id: last_weams_file_id, 
					raw_file: { type: @rf[:type], upload: @rf[:upload] } 

				expect(File.exists?(@old_weams_file)).not_to be_truthy
				expect(File.exists?(csv_file)).to be_truthy				
			end

			it "creates a timestamped csv_file" do
				put :update, id: last_weams_file_id, 
					raw_file: { type: @rf[:type], upload: @rf[:upload] } 

				expect(File.exist?(csv_file)).to be_truthy
			end

			it "redirects to the show page" do
				put :update, id: last_weams_file_id, 
					raw_file: { type: @rf[:type], upload: @rf[:upload] } 

      	expect(response).to redirect_to WeamsFile.last
    	end		
		end

		context "having invalid form input" do
			let(:last_file_id) { WeamsFile.last.id }
			
			before(:each) do
				create :weams_file_source

				post :create, raw_file: generate_create_attributes
				@old_weams_file = Rails.root.join('data', WeamsFile.last.name)
			end

			context "with a non-valid raw_file_source" do
				before(:each) do
					@rf = generate_create_attributes
					@rf[:type] = "SomeNonsense"
				end

				it "does not create a new raw_file record" do
					expect{ 
						post :update, id: last_file_id, raw_file: @rf 
					}.to change(RawFile, :count).by(0)
				end

				it "does not add a new csv file to the server" do
					expect{ 
						post :update, id: last_file_id, raw_file: @rf 
					}.to change{ Dir.entries(csv_dir).length }.by(0)
				end

				it "does not delete the last raw file" do
					post :create, raw_file: generate_create_attributes
					last_file = Rails.root.join('data', WeamsFile.last.name)

					RawFileSource.last.destroy
					post :create, raw_file: @rf
					expect(File.exist?(last_file)).to be_truthy
				end

				it "re-renders the new method" do
					post :create, raw_file: @rf
      		expect(response).to render_template :new
    		end
			end 	
	
			context "with a invalid upload file" do
				before(:each) do
					@rf = generate_create_attributes(false)
				end

				it "does not create a new raw_file record" do
					expect{ post :create, raw_file: @rf}.to change(RawFile, :count).by(0)
				end

				it "does not add a new csv file to the server" do
					post :create, raw_file: @rf
					expect{ post :create, raw_file: @rf }.to change{ Dir.entries(csv_dir).length }.by(0)
				end

				it "does not delete the last raw file" do
					rf = generate_create_attributes
					post :create, raw_file: rf

					rf[:upload] = nil
					post :update, id: last_file_id, raw_file: rf
					expect(File.exist?(csv_file)).to be_truthy
				end

				it "re-renders the new method" do
					post :create, raw_file: @rf
      		expect(response).to render_template :new
    		end
			end 	
		end
	end

	describe "DELETE destroy" do
		login_user
		render_views

		let(:csv_dir) { Rails.root.join('data') }

		before(:each) do
			create :weams_file_source
			@rf = generate_create_attributes

			post :create, raw_file: @rf
			@last_weams = WeamsFile.last
		end

		after(:each) do
			File.delete(csv_file) if WeamsFile.last.present? && File.exist?(csv_file)
		end

		context "with a valid id" do
			it "deletes a raw file record" do
				expect{ delete :destroy, id: @last_weams.id }.to change(WeamsFile, :count).by(-1)
			end

			it "deletes a raw file csv" do
				csv_file = Rails.root.join('data', WeamsFile.last.name)

				delete :destroy, id: @last_weams.id
				expect(File.exist?(csv_file)).not_to be_truthy
			end

			it "redirects to the index page" do
				delete :destroy, id: @last_weams.id
	      expect(response).to redirect_to raw_files_path
	  	end
	  end
	end

	describe "when downloading files" do
		login_user

		let(:csv_file) { Rails.root.join('data', WeamsFile.last.name) }
		let(:csv_dir) { Rails.root.join('data') }

		before(:each) do
			create :weams_file_source

			post :create, raw_file: generate_create_attributes
			@last_weams = WeamsFile.last
		end

		after(:each) do
			File.delete(csv_file) if File.exist?(csv_file)
		end
		
		describe "the GET send_csv_file" do
			it "assigns a path to the server raw file" do
				get :send_csv_file, id: @last_weams.id	
			
				expect(assigns(:path)).to eq(Rails.root.join('data', @last_weams.name))					
			end

			it "downloads a csv file" do
				get :send_csv_file, id: @last_weams.id	
			
				expect(response.header['Content-Type']).to eq('text/csv')			
			end
		end

		describe "displaying links" do
			render_views

			context "on the show page" do
				it "don't appear if raw file doesn't exist" do
					File.delete(csv_file) if File.exist?(csv_file)
					get :show, id: @last_weams.id

					expect(response.body).not_to match Regexp.new("Download #{@last_weams.name}")
				end
			end

			it "puts a download link if the latest raw file exists" do
				get :show, id: @last_weams.id
				expect(response.body).to match Regexp.new("Download #{@last_weams.name}")
			end

			context "on the index page" do
				it "puts a download link if the latest raw file exists" do
					get :index
					expect(response.body).to match Regexp.new("Download")
				end

				it "doesn't put a download link if the latest raw file doesn't exist" do
					File.delete(csv_file) if File.exist?(csv_file)
					get :index

					expect(response.body).not_to match Regexp.new("Download #{@last_weams.name}")
				end
			end
		end
	end
end
