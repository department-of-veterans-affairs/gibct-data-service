RSpec.shared_examples "a raw file sti model" do |model|
	describe "when being created" do
		context "with a factory" do
      it "that factory is valid" do
        expect(create model).to be_valid
      end
    end

		context "raw file sources" do
			it "are required" do
				expect(build model, use_source: false).to_not be_valid 
			end
		end

		context "sti types" do
			it "are required" do
				expect(build model, use_type:false).to_not be_valid 
			end
		end

		context "upload dates" do
			it "are required" do
				expect(build model, use_upload: false).to_not be_valid 
			end
		end

		context "names" do
			it "are required" do
				expect(build model, use_name: false).to_not be_valid 
			end
		end
	end

	describe "when getting the model name" do
		it "always returns the RawFile model name" do
			expect(build(model).class.model_name).to eq('RawFile')
		end
	end

	describe "when discovering the raw file source" do
		it "returns a name based on the class name" do
			expect(build(model).class_to_source).to eq(model.to_s)
		end
	end

	describe "when building the server name" do
		it "combines the upload date with the name" do
			wf = build(model)
			sn = wf.upload_date.strftime("%y%m%d%H%M%S%L_#{wf.class_to_source}.csv")
			expect(wf.to_server_name).to eq(sn)
		end
	end
end