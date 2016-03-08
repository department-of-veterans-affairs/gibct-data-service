require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe RawFilesController, type: :controller do

	#############################################################################
	## generate_create_attributes
	## Generates attributes used in create methods.
	#############################################################################
	def generate_create_attributes(use_upload = true, use_weams = true)
		rf = attributes_for :weams_file

		if use_weams
			rfs = create :weams_file_source
			rf[:weams_file_source_id] = rfs.id
		end

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
		
		context "having valid form input" do
			before(:each) do
				@rf = generate_create_attributes
			end

			it "creates a new raw_file record" do
				expect{ post :create, raw_file: @rf }.to change(WeamsFile, :count).by(1)
			end	

			it "updates its source's csv_file data" do
				expect{ post :create, raw_file: @rf }.to change{ CsvFile.first.updated_at }
			end

			it "modifies the data in the csv_file" do
				old_data = RawFileSource.find(@rf[:weams_file_source_id]).csv_file.data
				post :create, raw_file: @rf
				new_data = RawFileSource.find(@rf[:weams_file_source_id]).csv_file.data

				expect(old_data).not_to eq(new_data)
			end

			it "redirects to the show page" do
				post :create, raw_file: @rf
      	expect(response).to redirect_to WeamsFile.last
    	end		
		end

		context "having invalid form input" do
			context "with a non-valid raw_file_source" do
				before(:each) do
					@rf = generate_create_attributes(true, false)
					@rf[:type] = "blah blah"
				end

				it "does not create a new raw_file record" do
					expect{ post :create, raw_file: @rf }.to change(RawFile, :count).by(0)
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

				it "does not modify the data in the csv_file" do
					old_data = RawFileSource.find(@rf[:weams_file_source_id]).csv_file.data
					post :create, raw_file: @rf
					new_data = RawFileSource.find(@rf[:weams_file_source_id]).csv_file.data

					expect(old_data).to eq(new_data)
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
		
		before(:each) do
			post :create, raw_file: generate_create_attributes

			@rf_record = WeamsFile.first
			@rf = generate_create_attributes(true, false)

			@old_csv = @rf_record.raw_file_source.csv_file
			@old_csv.data = "0"
			@old_csv.save!
		end

		context "having valid form input" do
			it "doesn't create a new raw_file record" do
				expect{ 
					put :update, id: @rf_record.id, 
					raw_file: { type: @rf[:type], upload: @rf[:upload] } 
				}.to change(RawFile, :count).by(0)
			end	

			it "changes the csv_file data" do
				put :update, id: @rf_record.id, 
					raw_file: { type: @rf[:type], upload: @rf[:upload] } 

				@new_csv = WeamsFile.find(@rf_record.id).raw_file_source.csv_file				
				expect(@old_csv.data).not_to eq(@new_csv.data)
			end	

			it "redirects to the show page" do
				put :update, id: @rf_record.id, 
					raw_file: { type: @rf[:type], upload: @rf[:upload] } 

      	expect(response).to redirect_to @rf_record
    	end		
		end

		context "having invalid form input" do
			context "with a non-valid raw_file_source" do
				before(:each) do
					@rf[:type] = "SomeNonsense"
				end

				it "doesn't create a new raw_file record" do
					expect{ 
						put :update, id: @rf_record.id, 
						raw_file: { type: @rf[:type], upload: @rf[:upload] } 
					}.to change(RawFile, :count).by(0)
				end	

				it "does not change the csv_file data" do
					put :update, id: @rf_record.id, 
						raw_file: { type: @rf[:type], upload: @rf[:upload] } 

					@new_csv = WeamsFile.find(@rf_record.id).raw_file_source.csv_file				
					expect(@new_csv.data).to eq("0")
				end	

				it "re-renders the edit method" do
					put :update, id: @rf_record.id, 
						raw_file: { type: @rf[:type], upload: @rf[:upload] }       		

					expect(response).to render_template :edit
    		end
			end 	
	
			context "with a invalid upload file" do
				it "does not create a new raw_file record" do
					expect{ 
						put :update, id: @rf_record.id, 
						raw_file: { type: @rf[:type], upload: nil } 
					}.to change(RawFile, :count).by(0)
				end

				it "does not change the csv_file data" do
					put :update, id: @rf_record.id, 
						raw_file: { type: @rf[:type], upload: nil } 

					@new_csv = WeamsFile.find(@rf_record.id).raw_file_source.csv_file				
					expect(@new_csv.data).to eq("0")
				end	

				it "re-renders the edit method" do
					put :update, id: @rf_record.id, 
						raw_file: { type: @rf[:type], upload: nil }       		

					expect(response).to render_template :edit
    		end
			end 	
		end
	end

	describe "DELETE destroy" do
		login_user
		render_views

		before(:each) do
			@rf = generate_create_attributes

			post :create, raw_file: @rf
			@rf_record = WeamsFile.last
		end

		context "with a valid id" do
			it "deletes a raw file record" do
				expect{ delete :destroy, id: @rf_record.id }.to change(WeamsFile, :count).by(-1)
			end

			it "deletes csv data if the latest" do
				raw_file_source = @rf_record.raw_file_source

				delete :destroy, id: @rf_record.id
				expect(raw_file_source.csv_file.data).to eq("0")
			end

			it "does not delete csv data if not the latest" do
				raw_file_source = @rf_record.raw_file_source

				post :create, raw_file: generate_create_attributes(true, false)

				delete :destroy, id: @rf_record.id
				expect(raw_file_source.csv_file.data).not_to eq("0")
			end

			it "redirects to the index page" do
				delete :destroy, id: @rf_record.id
	      expect(response).to redirect_to raw_files_path
	  	end
	  end
	end

	describe "when downloading files" do
		login_user

		before(:each) do
			post :create, raw_file: generate_create_attributes
			@rf_record = WeamsFile.last
		end
		
		describe "the GET send_csv_file" do
			it "downloads a csv file" do
				get :send_csv_file, id: @rf_record.id	
			
				expect(response.header['Content-Type']).to eq('application/octet-stream')			
			end
		end

		describe "links to downlad raw file" do
			render_views

			context "on the show page" do
				it "do not appear if this is not the latest raw file" do
					post :create, raw_file: generate_create_attributes(true, false)
					get :show, id: @rf_record.id

					expect(response.body).not_to match Regexp.new("Download #{@rf_record.name}")
				end
		
				it "puts a download link if the latest raw file" do
					get :show, id: @rf_record.id
					expect(response.body).to match Regexp.new("Download #{@rf_record.name}")
				end
			end

			context "on the index page" do
				it "puts a download link if it is the latest raw file" do
					get :index
					expect(response.body).to match Regexp.new("Download")
				end

				it "does not put a download link if it is the latest raw file" do
					post :create, raw_file: generate_create_attributes(true, false)
					get :index

					expect(response.body).not_to match Regexp.new("^.+#{@rf_record.name}.+Download$")
				end
			end
		end
	end
end
