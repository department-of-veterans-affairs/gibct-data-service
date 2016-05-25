RSpec.shared_examples "a csv file sti model" do |model|
  describe "when being created" do
    context "with a model" do
      it "that model is valid" do
        expect(create model).to be_valid
      end
    end

    context "sti types" do
      it "are required" do
        expect(build model, use_type: false).to_not be_valid 
      end

      it "can produce a readable type" do
        readable = model.to_s.split('_')
          .map(&:capitalize).join(" ").gsub(/csv file/i, '').strip
        expect(build(model).humanize_type).to eq(readable)
      end
    end

    context "are assigned names" do
      it "that are timestamped when created" do
        csv = create model
        expect(csv.name).to match(Regexp.new("^\\d{15}_#{csv.class_to_type}.csv$")) 
      end
    end

    context "are assigned upload dates" do
      it "that reflect when created" do
        csv = create model
        expect(csv.upload_date).to be_present
      end

      it "can display a readable date" do
        csv = create model
        expect(csv.humanize_date).to eq(csv.upload_date.strftime("%B %d, %Y"))

        csv.upload_date = nil
        expect(csv.humanize_date).to eq('-')        
      end
    end

    context "associated binary storage" do
      it "is created if not already existing" do
        csv = build model
        expect(CsvStorage.find_by(csv_file_type: csv.type)).to be_nil
        expect{ csv.save }.to change(CsvStorage, :count).by(1)
        expect(CsvStorage.find_by(csv_file_type: csv.type)).not_to be_nil
      end

      it "is not created if already existing" do
        csv = build model
        create :csv_storage, csv_file_type: csv.type
        expect{ csv.save }.to change(CsvStorage, :count).by(0)
      end

      it "changes the contents of the data_store" do
        csv = build model
        before_data = create(:csv_storage, csv_file_type: csv.type).data_store
        csv.save
        after_data = CsvStorage.find_by(csv_file_type: csv.type)

        expect(before_data).not_to eq(after_data)
      end

      it "will not save csv_file if storage creation fails" do
        csv = build model
        store = create :csv_storage, csv_file_type: csv.type

        allow(store).to receive(:save) { false }
        allow(CsvStorage).to receive(:find_or_create_by) { store }

        expect{ csv.save }.to change(csv.class, :count).by(0)
      end 
    end
  end

  describe "when finding out about itself" do
    it "always returns the CsvFile model name" do
      expect( build(model).class.model_name ).to eq('CsvFile')
    end

    it "knows the last upload date" do
      csv1 = create(model)
      csv2 = create(model)

      expect(CsvFile.count).to eq(2)
      expect(csv1.class.last_upload_date.to_i).to eq(csv2.upload_date.to_i)
    end

    it "knows the last uploaded csv file" do
      csv1 = create(model)
      csv2 = create(model)

      expect(csv1.class.last_upload).to eq(csv2)
    end

    it "knows if its the last instance" do
      csv1 = create(model)
      csv2 = create(model)

      expect(csv1.class.first).not_to be_latest
    end
  end

  describe "when discovering what derived class it is" do
    it "returns a name based on the its class" do
      expect(build(model).class_to_type).to eq(model.to_s)
    end
  end

  describe "when being destroyed" do
    before(:each) do
      @csv = create(model)
    end

    it "is no longer persisted" do
      @csv.destroy
      expect(@csv).not_to be_persisted
    end

    it "destroys data store if last saved" do
      @csv.destroy
      expect(CsvStorage.find_by(csv_file_type: @csv.type).data_store).to be_blank
    end

    it "does not destroy data store if not last saved" do
      create(model)
      @csv.destroy
      expect(CsvStorage.find_by(csv_file_type: @csv.type).data_store).not_to be_blank
    end
  end
end