# frozen_string_literal: true
RSpec.shared_examples 'a loadable model' do |options|
  let(:name) { described_class.name.underscore }
  let(:factory_name) { name.to_sym }

  before(:each) do
    create_list factory_name, 5
  end

  it 'CSV_CONVERTER_INFO must be defined for loadable classes' do
    expect(described_class::CSV_CONVERTER_INFO).not_to be_nil
  end

  describe 'when loading' do
    context 'with an error-free csv file' do
      let(:csv_file) { File.new(Rails.root.join('spec/fixtures', "#{name}.csv")) }

      it 'deletes the old table content' do
        expect { described_class.load(csv_file, options) }.to change { described_class.count }.from(5).to(2)
      end

      it 'loads the table' do
        results = described_class.load(csv_file, options)

        expect(results.num_inserts).to eq(1)
        expect(results.ids.length).to eq(2)
        expect(results.failed_instances.length).to eq(0)
      end
    end

    context 'with a problematic csv file' do
      let(:csv_file_invalid) { File.new(Rails.root.join('spec/fixtures', "#{name}_invalid.csv")) }
      let(:csv_rows) { 2 }

      it 'does not load invalid records into the table' do
        results = described_class.load(csv_file_invalid, options)

        expect(results.num_inserts).to eq(1)
        expect(results.ids.length).to eq(1)
        expect(results.failed_instances.length).to eq(1)
      end
    end
  end
end
