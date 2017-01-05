# frozen_string_literal: true
RSpec.shared_examples 'a loadable model' do |options|
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }

  before(:each) do
    create_list factory_name, 5
  end

  describe "#{described_class}::MAP" do
    it 'must be defined for loadable classes' do
      expect(described_class::MAP).not_to be_nil
    end
  end

  describe 'load' do
    context 'with an error-free csv file' do
      let(:csv_file) { File.new(Rails.root.join('spec/fixtures', "#{name}.csv")) }

      it "deletes all records in the #{described_class.name.pluralize} table before loading" do
        expect { described_class.load(csv_file, options) }.to change { described_class.count }.from(5).to(2)
      end

      it "loads the #{described_class.name.pluralize} table from a CSV file" do
        results = described_class.load(csv_file, options)

        expect(results.failed_instances).to be_blank
        expect(results.num_inserts).to eq(1)
        expect(results.ids).to match_array(Weam.pluck(:id).map(&:to_s))
      end
    end

    context 'with a problematic csv file' do
      let(:csv_file_invalid) { File.new(Rails.root.join('spec/fixtures', "#{name}_invalid.csv")) }
      let(:csv_file_dup) { File.new(Rails.root.join('spec/fixtures', "#{name}_dup.csv")) }

      it "does not load invalid records into the #{described_class.name.pluralize} table" do
        results = described_class.load(csv_file_invalid, options)

        expect(results.failed_instances.length).to eq(1)
        expect(results.failed_instances.first).to be_an_instance_of(described_class)
      end

      it 'ignores duplicated rows silently' do
        results = described_class.load(csv_file_dup, options)

        expect(results.failed_instances).to be_blank
        expect(Weam.first.institution).to eq('1ST ROW')
      end
    end
  end
end
